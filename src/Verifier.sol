// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

contract Verifier {
    function verify(
        bytes calldata _proof,
        bytes32[] calldata _publicInputs
    ) external view returns (bool) {
        return true;
    }

    function verifsasay(
        bytes calldata _proof,
        bytes32[] calldata _publicInputs
    ) external view returns (bool) {
        return true;
    }
}
