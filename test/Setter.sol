// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

contract SimpleSetter {
    uint256 private value;

    // Event to emit when the value is set
    event ValueSet(uint256 newValue);

    // Function to set the value
    function setValue(uint256 newValue) public {
        value = newValue;
        emit ValueSet(newValue);
    }

    // Function to get the value
    function getValue() public view returns (uint256) {
        return value;
    }
}
