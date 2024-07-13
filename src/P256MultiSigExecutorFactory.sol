// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {P256MultiSigExecutor} from "./P256MultiSigExecutor.sol";

contract P256MultiSigExecutorFactory {
    address public immutable verifier;

    constructor(address _verifier) {
        verifier = _verifier;
    }

    function deployP256MultiSigExecutorModule(
        bytes32 moduleSalt
    ) external returns (address) {
        // Deploy recovery module
        address p256MultiSigExecutorAddress = address(
            new P256MultiSigExecutor{salt: moduleSalt}(verifier)
        );

        return p256MultiSigExecutorAddress;
    }
}
