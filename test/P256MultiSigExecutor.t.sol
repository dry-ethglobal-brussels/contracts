// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
// import {Vm} from "forge-std/Vm.sol";
import {console2} from "forge-std/console2.sol";

import {MODULE_TYPE_EXECUTOR} from "modulekit/external/ERC7579.sol";
import {RhinestoneModuleKit, AccountInstance, ModuleKitHelpers} from "modulekit/ModuleKit.sol";

import {P256MultiSigExecutor} from "src/P256MultiSigExecutor.sol";
import {P256MultiSigExecutorFactory} from "src/P256MultiSigExecutorFactory.sol";
import {Verifier} from "src/Verifier.sol";
import {UltraVerifier} from "src/plonk_vk.sol";
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

    function testVerifier() public {
        UltraVerifier ultraVerifier = new UltraVerifier();
        bytes32[] memory publicInputs = new bytes32[](64);
        publicInputs = convertUint8ToBytes32(message, root);

        string
            memory _proof = "19a11ca57ae18808322313b6ab02560973fd1b736e1e92b2e7ecf821d023fb9c142c9362ae76aba2ebcb22a2c23686c24d8c7d4cc82fc431dd734273edba5bd60ddaccc9b57ad9a77f44832465a477feeb78cebe59e1795d464fec65f11db9eb22104e37b5d4e9c52de4839111e18de72aba67f6c093cfb39361062ce382679d21e02cf470d604bdef41798dc6946388c3e21f2506d5e04f93ea1b6d282dac6a08b8c7d9987b0cd42b2983fdb8f8c4a6b42803939b332b2fa635e35f1687a1f208396473520345362eccd2eb2013f91ed5f1795b0788e724430b1eae88b931e624e95c2ed4987318a102109a494171e87f5e667b1d30c213a00979166155ce1902c984620c63899401027b4068c8ffc1d51343558d86fa5068182becc1db7e8a222f3f8a9469e7cc65fe2e5264fc05542777c170fde6742c781d9eaf8f18ec9f1f54ff8097cedf69580ecfeae05aee28c5f8f95d2d75c4c70231550954d3039b0810df466d43f48e778f23c631bff4e77896d00b49b42cc6c0d1b5bc3377710d19a433db2b4a1ff34da30d8426e8bbae949ae1276690d2cb49dc401e4609829f1d554a1dcc5f5ece4231a532e36cec99705a837194fa6ced0ef10a6e28c0004d247a780e4e0e376b3cdb9f1a438677f9e3fa7de9e5e3c2c04a17e09724e333dc1b45a562f3d337f4e9da31e13dd404db605d2b17abfee1f6c3945f2fc01bb5f11acf6f5c394ffa8959f7e261c471cdeffa524f4fd92f8964adae3a81aac344841c9c77160cfdb1aca97af713e36d163032a187c37d856553f11410a9207ea9d2212f2c02560c710d209069f61d064ae776f504f660effce8dc14239de87f427f21c6739149556ddf2a8d26ba8af25eb380f300d3f3a38fd5cd9b0530fd1a752718572cbee5bea7a137ecbfe45e387ed46198919685757b77cf1c38a3ebea97a90197c41da9a5583e74159d9dc0178dd7d706e1172d69bcac88ca9ca0958acf22224e25037415ead39b33d11327d96a87f4c37a27e9a178a488e9afa8014090632ab94cbb940d08ff739369e070ceb6b539e823f60c91afa8ba93c17856bd0a7c004906edcfc5f14cdba4df23628dcd02f1df6af28d108b763315af5ef164e4512f834487aa9b10bb6e1adf38183bcf5036488cd1c4dc4ab8d61b894a93ff0a370b9302de0aa9fa74c134e10dabc0f8c6ef20aaee9cde5c274607a3e770eff4da2d9adf770deea9f6854bc904b59896aafc7b348a04c0204dafd4ff5483db6e2c136d541b33c812e359b2bcbfdbd80ac8afbfb25c1c03d6f0c81a8a2f4910e6dc0e9913df64e34d722ee9820f2dca1d34f4d10f6364220f87cfe7adc4d5d0d0d809e2f365d8e2a74f6aec33649b0c7de0414392a3fddb0539dcd3c8b0980029891aa6000d834fdd750f8889fb0a7206bf15e3cf722534ddecb64a5ff075da7b9100151c179e557c033a150a6ce51e4b5e353de5a2ac7ea3e5d64c7bbbe92a1deb15cb9333e4aa4f5756ab74a601d4591d5a866d02ce2b987aa7971400c2742b42302a39cdb8b892ebbf8e3f0f5a53a48db4d394bdf7bbaa09c5f5235ec8b023740d86e9ff8a07a04a538d88a68a00a294c619bbc6d88f70cee5201a786b8ced2728187a76b127709cb2ae1acc8767d37da943989e93776adf8d2ca489d90800462f64d263a3ecc594fef9672542c15b1895f10792b912cdb6985f6e9515f7d73c17c5d943977812e2b950260dc4548f814a28158f5890c50715b2ba8f6b4d75e22f630660ce8ab2f94683f53737755d3ac95c2b3c280a46e8f6c12180e793d62f055ffc0399a97e345d5e5b3aafde8b234d1ec51b786cb4677d17446a88e936f31073e804043b70b39166db95a7bbf24f684314453e3bb787c83a846e7341c91c281482b8748b71bc7068ee18c4ccbcacba5d57a626630de7b3b655a0d511cb5811d4cbce2728ca76a2841949c837a38bd63e9bb25269057c2b7892854cf3d74202d90b015c89a39094763bab1a1911e367251cb2b6771fe6ccb5f242027c32cd077bdf87ff411a646cef7f66b911c9aa59493214e59d86f143b367ee43de31532f75e0dce0926d85923338798e18d417ccfa66aefd3d91e30cfd5718c485e8dd0b2e5ecdc193d0db0cde4a0153f08cb697df6a4fd3edf64005b1a272762881cb2065bfd0f6e2603c1597f2fdb96599fded198a192d629f815b1b9a313910076a1cd95adf965bc2a45789c4a9fd1e765df8e119e2f17cd7ef5267bb2dea1280241721f4a0a82e77aea416eeb425a720a2b5f6e1252714a99e50c69f4126f71c78057d2eaeba51d52b0c95c224b60e9ec88e04acf26d075a9dbbc4a2a1d3e7c05e21f7e8342e0a83f9fb8dbd2aea8796841b4f5b1359bde94d29e03d1415978a010b4f39709eb3988be4ab79ee6d85b1a4fd2f946cde9ab51a6e6e94e02c8d2b4800d56ab4d8f3429b7758076c119b8d8f89ee2bd3a2a2c579d4bf5b20dad7616e2654f91768c08a87179346ecb68030733fa9887f5053e26aec09529937b3982214db98e5f8cf8476348ce39264f555d621c8c55fa5a701400d0423a2f5d2979c040b2806ce36d1effb9c4d9d41c92bb4b19703e410359a7d0933be5116c768f72a416bc9e4506b9a2f5c96a36fa9aa8a5f26caff6d9a32a849c61a294ef32afc2592a0c934d1435dd06198f63275c37ec85d4ca45635d1baebd425c1206049b6056b9cab2ffbf670f5ba095756f04fdffde1aa2e6f8ae7f5258858d9bca070761a5a32d8283fd62d919517e0c6dff0efc830bdac50637fe7a6b511b7515e236518e9bd5ae4a126882e4de6578a853770b54795dda875c600f39fc84b01d0ab5c03230011afde97557cbc5ec982f79ac0a1d6e2f0c47bb8dde3c9a422987a44bd00c07b682bc9a7c384d56f4c8ce6733e21b0a140ed37fb6e3be747f80222f35b20f1f4cb0fa3f9306e98386cd488cb6c7cb8d8de728489a7aeb99d468579856d2ae7f88fb75f20d6d3b41aa7ebbe2e3860f750f0585d08bbf4e9974576f13855";
        assertEq(
            ultraVerifier.verify(vm.parseBytes(_proof), publicInputs),
            true
        );
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
