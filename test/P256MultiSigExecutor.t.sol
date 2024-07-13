// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console2} from "forge-std/console2.sol";

import {MODULE_TYPE_EXECUTOR} from "modulekit/external/ERC7579.sol";
import {RhinestoneModuleKit, AccountInstance, ModuleKitHelpers} from "modulekit/ModuleKit.sol";

import {P256MultiSigExecutor} from "src/P256MultiSigExecutor.sol";
import {P256MultiSigExecutorFactory} from "src/P256MultiSigExecutorFactory.sol";
import {Verifier} from "src/Verifier.sol";
import {SimpleSetter} from "./Setter.sol";
import {Inputs} from "./Input.sol";

contract P256MultiSigExecutorTest is RhinestoneModuleKit, Test, Inputs {
    using ModuleKitHelpers for *;

    P256MultiSigExecutorFactory p256MultiSigExecutorFactory;
    P256MultiSigExecutor p256MultiSigExecutor;
    Verifier verifier;
    SimpleSetter setter;
    AccountInstance instance;
    bytes callData;

    function setUp() public {
        verifier = new Verifier();
        p256MultiSigExecutorFactory = new P256MultiSigExecutorFactory(
            address(verifier)
        );
        p256MultiSigExecutor = P256MultiSigExecutor(
            p256MultiSigExecutorFactory.deployP256MultiSigExecutorModule(
                bytes32(0) // moduleSalt
            )
        );
        setter = new SimpleSetter();
        instance = makeAccountInstance("account");
        callData = abi.encodeWithSignature("setValue(uint256)", 1);
    }

    function testExecuteWithThreshold1() public {
        bytes memory moduleInstallData = abi.encode(
            bytes("0"), // isInstalledContext
            bytes32(0), // merkle root
            1
        );

        // Install modules
        instance.installModule({
            moduleTypeId: MODULE_TYPE_EXECUTOR,
            module: address(p256MultiSigExecutor),
            data: moduleInstallData
        });

        bytes[] memory proofs = new bytes[](1);
        proofs[0] = proof1;

        bytes memory proofData = abi.encode(proofs);

        p256MultiSigExecutor.execute(
            instance.account,
            address(setter),
            0,
            callData,
            proofData
        );

        uint value = setter.getValue();
        assertEq(value, 1);
    }

    function testExecuteWithThreshold2() public {
        bytes memory moduleInstallData = abi.encode(
            bytes("0"), // isInstalledContext
            bytes32(0), // merkle root
            2
        );

        // Install modules
        instance.installModule({
            moduleTypeId: MODULE_TYPE_EXECUTOR,
            module: address(p256MultiSigExecutor),
            data: moduleInstallData
        });

        bytes[] memory proofs = new bytes[](2);
        proofs[0] = proof1;
        proofs[1] = proof2;

        bytes memory proofData = abi.encode(proofs);

        p256MultiSigExecutor.execute(
            instance.account,
            address(setter),
            0,
            callData,
            proofData
        );

        uint value = setter.getValue();
        assertEq(value, 1);
    }

    function testExecuteWithThreshold2Separate() public {
        bytes memory moduleInstallData = abi.encode(
            bytes("0"), // isInstalledContext
            bytes32(0), // merkle root
            2
        );

        // Install modules
        instance.installModule({
            moduleTypeId: MODULE_TYPE_EXECUTOR,
            module: address(p256MultiSigExecutor),
            data: moduleInstallData
        });

        bytes[] memory proofs1 = new bytes[](1);
        proofs1[0] = proof1;

        bytes[] memory proofs2 = new bytes[](1);
        proofs2[0] = proof2;

        bytes memory proofData1 = abi.encode(proofs1);
        bytes memory proofData2 = abi.encode(proofs2);

        p256MultiSigExecutor.execute(
            instance.account,
            address(setter),
            0,
            callData,
            proofData1
        );

        p256MultiSigExecutor.execute(
            instance.account,
            address(setter),
            0,
            callData,
            proofData2
        );

        uint value = setter.getValue();
        assertEq(value, 1);
    }

    function testExecuteFailWithThreshold2() public {
        bytes memory moduleInstallData = abi.encode(
            bytes("0"), // isInstalledContext
            bytes32(0), // merkle root
            2
        );

        // Install modules
        instance.installModule({
            moduleTypeId: MODULE_TYPE_EXECUTOR,
            module: address(p256MultiSigExecutor),
            data: moduleInstallData
        });

        bytes[] memory proofs1 = new bytes[](1);
        proofs1[0] = proof1;

        bytes memory proofData1 = abi.encode(proofs1);

        p256MultiSigExecutor.execute(
            instance.account,
            address(setter),
            0,
            callData,
            proofData1
        );

        uint value = setter.getValue();
        assertEq(value, 0); // not 1
    }
}
