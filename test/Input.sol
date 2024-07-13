pragma solidity ^0.8.25;

contract Inputs {
    uint8[] public message = [
        58,
        47,
        28,
        212,
        12,
        195,
        224,
        102,
        123,
        153,
        145,
        57,
        46,
        31,
        172,
        198,
        1,
        223,
        56,
        171,
        37,
        251,
        187,
        20,
        62,
        243,
        212,
        89,
        238,
        217,
        47,
        192
    ];

    uint8[] public root = [
        94,
        166,
        212,
        49,
        137,
        188,
        187,
        221,
        236,
        134,
        174,
        167,
        250,
        155,
        45,
        203,
        248,
        61,
        123,
        254,
        85,
        14,
        133,
        236,
        121,
        3,
        89,
        205,
        191,
        175,
        245,
        38
    ];
    bytes public proof1 = bytes("proof1");
    bytes public proof2 = bytes("proof2");
    bytes public proof3 = bytes("proof3");

    function convertUint8ToBytes32(
        uint8[] memory _array
    ) public pure returns (bytes32[] memory) {
        bytes32[] memory array = new bytes32[](32);

        for (uint i; i < 32; i++) {
            array[i] = bytes32(uint256(_array[i]));
        }
        return array;
    }
    function convertUint8ToBytes32(
        uint8[] memory _array1,
        uint8[] memory _array2
    ) public pure returns (bytes32[] memory) {
        bytes32[] memory array = new bytes32[](64);

        for (uint i; i < 32; i++) {
            array[i] = bytes32(uint256(_array1[i]));
            array[i + _array1.length] = bytes32(uint256(_array2[i]));
        }

        return array;
    }
}

// 1: contract: test with pedro's proofs and verifier ( not execHash )
// -- lets generate proofs or use single one.
// -- local
// -- to see if p256 verifier works
// 2: contract: test with theo's real face id proofs
// -- sepolia
// -- use relayer
// -- use execHash
// -- mb get pub keys from pedro and theos devices

// 3: write mobile scripts using zk-kit

// 4: final demo:
// -- manually agg pub keys and construct merkle tree
// -- mb hardcode tree params for each pub key then no need for relayer's tree service
// -- accounts and modules are already deployed
// -- just show signing flow
