// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

// forge script script/Deploy.s.sol:DeployModule --broadcast --rpc-url https://eth-sepolia.g.alchemy.com/v2/JG3mOl7GCd3oU_skAHEpl7qWDsoyitZA --legacy

import {console2} from "forge-std/console2.sol";
import {Script} from "forge-std/Script.sol";
import {P256MultiSigExecutor} from "src/P256MultiSigExecutor.sol";

contract DeployModule is Script {
    address deployerAddress = vm.envAddress("ADDRESS");
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    P256MultiSigExecutor p256Validator;

    function run() external {
        vm.startBroadcast(deployerPrivateKey);

        p256Validator = new P256MultiSigExecutor(address(0));

        console2.logAddress(address(p256Validator));

        vm.stopBroadcast();
    }
}
