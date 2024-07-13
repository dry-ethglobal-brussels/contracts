// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IP256MultiSigExecutor {
    function execute(
        address account,
        address target,
        uint256 value,
        bytes calldata callData,
        bytes memory proofData
    ) external;

    function changeMultisigConfig(
        bytes32 newOwnersMerkleRoot,
        uint threshold
    ) external;

    function getMultisigConfig(
        address account
    )
        external
        view
        returns (bytes32 ownersMerkleRoot, uint threshold, bool enabled);
}
