// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

// forge script script/Deploy.s.sol:DeployModule --broadcast --rpc-url https://eth-sepolia.g.alchemy.com/v2/JG3mOl7GCd3oU_skAHEpl7qWDsoyitZA --legacy

import {console2} from "forge-std/console2.sol";
import {Script} from "forge-std/Script.sol";
import {P256MultiSigExecutor} from "src/P256MultiSigExecutor.sol";
import {UltraVerifier as Verifier} from "src/plonk_vk.sol";

contract DeployModule is Script {
    address deployerAddress = vm.envAddress("ADDRESS");
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    Verifier verifier;
    P256MultiSigExecutor p256MultisigExecutor;

    function run() external {
        vm.startBroadcast(deployerPrivateKey);

        verifier = new Verifier();
        p256MultisigExecutor = new P256MultiSigExecutor(address(verifier));

        console2.logAddress(address(verifier));
        console2.logAddress(address(p256MultisigExecutor));

        vm.stopBroadcast();
    }
}
