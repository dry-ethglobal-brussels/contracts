// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC7579ExecutorBase} from "@rhinestone/modulekit/src/Modules.sol";
import {IERC7579Account} from "erc7579/interfaces/IERC7579Account.sol";
import {IModule} from "erc7579/interfaces/IERC7579Module.sol";
import {IP256MultiSigExecutor} from "./interfaces/IP256MultiSigExecutor.sol";
// import {Verifier} from "./Verifier.sol";
import {UltraVerifier as Verifier} from "./plonk_vk.sol";

import {console2} from "forge-std/console2.sol";

// why not validator but executor?
// 1: with relayer, face-id signers dont need to send txs by themselves.
// 2: complexity. if this is validator, then we also need executor/hook. if executor, just conditional execution. simple as that.
// 3: execHash doesnt necessarily need to be userOpHash.

/**
 * @title P256MultiSigExecutor
 * @notice TODO: add description
 */
contract P256MultiSigExecutor is ERC7579ExecutorBase, IP256MultiSigExecutor {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    CONSTANTS & STORAGE                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * Trusted email recovery manager contract that handles recovery requests
     */
    address public immutable verifier;

    enum ExecutionStatus {
        NONE,
        PENDING,
        EXECUTED
    }

    struct Execution {
        uint approvalCount;
        mapping(bytes32 => bool) nullifiers; // signature ( hash ) => true
        ExecutionStatus status;
    }

    struct MultisigConfig {
        bytes32 ownersMerkleRoot;
        uint threshold;
        bool enabled;
        // string credentialId
    }

    /**
     * Account address to authorized validator
     */
    mapping(address => MultisigConfig) public multisigConfigs;
    mapping(address => mapping(bytes32 execHash => Execution))
        public executions;

    // events
    event Executed();

    // errros
    error InvalidOnInstallData();
    error InvalidNullifier();
    error InvalidProof();
    error NotEnabled();

    constructor(address _verifier) {
        verifier = _verifier;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          CONFIG                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * Initializes the module with the threshold and guardians
     * @dev data is encoded as follows: abi.encode(validator, isInstalledContext, initialSelector,
     * guardians, weights, threshold, delay, expiry)
     *
     * @param data encoded data for recovery configuration
     */
    function onInstall(bytes calldata data) external override {
        if (data.length == 0) revert InvalidOnInstallData();
        address sender = msg.sender;
        (
            bytes memory isInstalledContext,
            bytes32 ownersMerkleRoot,
            uint256 threshold
        ) = abi.decode(data, (bytes, bytes32, uint256));

        multisigConfigs[sender] = MultisigConfig(
            ownersMerkleRoot,
            threshold,
            true
        );
    }

    /**
     * Handles the uninstallation of the module and clears the recovery configuration
     * @dev the data parameter is not used
     */
    function onUninstall(bytes calldata /* data */) external override {
        // multisigConfigs[msg.sender] = MultisigConfig(bytes32(0), 0, false);
        delete multisigConfigs[msg.sender];
    }

    /**
     * Check if the module is initialized
     * @param smartAccount The smart account to check
     * @return true if the module is initialized, false otherwise
     */
    function isInitialized(address smartAccount) public view returns (bool) {
        return multisigConfigs[smartAccount].enabled;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        MODULE LOGIC                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @notice Executes tx
     * @param account The account to execute tx
     */
    function execute(
        address account,
        address target,
        uint256 value,
        bytes calldata callData,
        bytes memory proofData
    ) external {
        if (!multisigConfigs[account].enabled) {
            revert NotEnabled();
        }

        // TODO: bytes32 message = construct msg here...
        // keccak256(account, target, value, calldata, chainid);
        // bytes32 execHash = keccak256(
        //     abi.encodePacked(account, target, value, callData, block.chainid)
        // );
        bytes32 execHash = keccak256(
            abi.encode(account, target, value, callData, block.chainid)
        );

        //  check verify proof
        // skip execution if threshold not met
        if (_verifyProof(account, execHash, proofData)) {
            _execute({
                account: account,
                to: target,
                value: value,
                data: callData
            });
        }

        emit Executed();
    }

    // TODO: circuit should bind execHash
    /// params:
    /// - sender: account to execute recovery for
    /// - execHash: unique idenfitifer for the execution
    /// - proofData: proof data
    function _verifyProof(
        address account,
        bytes32 execHash,
        bytes memory proofData
    ) internal returns (bool) {
        bytes[] memory proofs = abi.decode(proofData, (bytes[]));

        // bytes32[] memory publicInputs = new bytes32[](2);
        // // publicInputs[0] = execHash;
        // publicInputs[0] = sha256(abi.encodePacked(execHash));
        // publicInputs[1] = multisigConfigs[account].ownersMerkleRoot;

        bytes32[] memory publicInputs = new bytes32[](64);
        publicInputs = expandTwoBytes32(
            sha256(abi.encodePacked(execHash)),
            multisigConfigs[account].ownersMerkleRoot
        );

        for (uint256 i = 0; i < proofs.length; i++) {
            bytes32 nullifier = keccak256(
                abi.encodePacked(execHash, proofs[i])
            );

            if (executions[account][execHash].nullifiers[nullifier]) {
                revert InvalidNullifier();
            }

            if (Verifier(verifier).verify(proofs[i], publicInputs)) {
                executions[account][execHash].nullifiers[nullifier] = true;
                executions[account][execHash].approvalCount++;
            }
        }

        return
            executions[account][execHash].approvalCount >=
            multisigConfigs[account].threshold;
    }

    function expandTwoBytes32(
        bytes32 data1,
        bytes32 data2
    ) public pure returns (bytes32[] memory) {
        bytes32[] memory expanded = new bytes32[](64);
        for (uint256 i = 0; i < 32; i++) {
            // Process first bytes32
            bytes32 temp1 = bytes32(uint256(uint8(data1[i])));
            expanded[i] = temp1;
            // Process second bytes32
            bytes32 temp2 = bytes32(uint256(uint8(data2[i])));
            expanded[i + 32] = temp2;
        }
        return expanded;
    }

    function changeMultisigConfig(
        bytes32 newOwnersMerkleRoot,
        uint threshold
    ) external {
        if (!multisigConfigs[msg.sender].enabled) {
            revert NotEnabled();
        }

        multisigConfigs[msg.sender] = MultisigConfig(
            newOwnersMerkleRoot,
            threshold,
            true
        );
    }

    function getMultisigConfig(
        address account
    )
        external
        view
        returns (bytes32 ownersMerkleRoot, uint threshold, bool enabled)
    {
        MultisigConfig memory config = multisigConfigs[account];
        return (config.ownersMerkleRoot, config.threshold, config.enabled);
    }

    function getCurrentApprovalCount(
        address account,
        bytes32 execHash
    ) external view returns (uint) {
        return executions[account][execHash].approvalCount;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         METADATA                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * Returns the name of the module
     * @return name of the module
     */
    function name() external pure returns (string memory) {
        return "P256MultiSig.P256MultiSigModule";
    }

    /**
     * Returns the version of the module
     * @return version of the module
     */
    function version() external pure returns (string memory) {
        return "0.0.1";
    }

    /**
     * Returns the type of the module
     * @param typeID type of the module
     * @return true if the type is a module type, false otherwise
     */
    function isModuleType(uint256 typeID) external pure returns (bool) {
        return typeID == TYPE_EXECUTOR;
    }
}
