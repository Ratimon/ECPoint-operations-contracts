//SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {Test,console2, stdError} from "@forge-std/Test.sol";
import {R1CSVerifier} from "@main/R1CSVerifier.sol";

contract R1CSVerifierTest is Test {
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

    address deployer = vm.addr(deployerPrivateKey);
    address alice = makeAddr("Alice");

    R1CSVerifier verifier;

    function setUp() public {
        vm.startPrank(deployer);

        vm.deal(deployer, 1 ether);
        vm.label(deployer, "Deployer");

        verifier = new R1CSVerifier();
        vm.label(address(verifier), "Verifier");

        vm.stopPrank();
    }


     // 1st: (1)x* (1)x + (-1)v1 = 0
    function test_verify_one() external {
 
        // poetry run pytest tests-python/test_r1cs_verifier.py
        // # Our witness vector is: [1 out x y v1 v2 v3 v4]
        // w  [ 1 22  1  2  1  4  4  4]

        // encrypted : X_1 = 1
        // X1 (1, 2)
        R1CSVerifier.G1Point memory X_1 = R1CSVerifier.G1Point({
            X: uint256(1),
            Y: uint256(2)
        });

        // encrypted : X_2 = 1
        // B2 ((10857046999023057135944570762232829481370756359578518086990519993285655852781, 11559732032986387107991004021392285783925812861821192530917403151452391805634), (8495653923123431417604973247489272438418190587263600148770280649306958101930, 4082367875863433681332203403145435568316851327593401208105741076214120093531))
        R1CSVerifier.G2Point memory X_2 = R1CSVerifier.G2Point({
            X: [
                uint256(11559732032986387107991004021392285783925812861821192530917403151452391805634),
                uint256(10857046999023057135944570762232829481370756359578518086990519993285655852781)
            ],
            Y: [
                uint256(4082367875863433681332203403145435568316851327593401208105741076214120093531),
                uint256(8495653923123431417604973247489272438418190587263600148770280649306958101930)
            ]
        });

        // encrypted : V1_1 = 1
        // V1_1 (1, 2)
        R1CSVerifier.G1Point memory V1_1 = R1CSVerifier.G1Point({
            X: uint256(1),
            Y: uint256(2)
        });

        bool isVerified = verifier.verify_one(X_1, X_2, V1_1);
        assertEq(isVerified, true);

    }

    // 2nd: (1)y* (1)y + (-1)v2 = 0
    function test_verify_two() external {
 
        // poetry run pytest tests-python/test_r1cs_verifier.py
        // # Our witness vector is: [1 out x y v1 v2 v3 v4]
        // w  [ 1 22  1  2  1  4  4  4]

        // encrypted : Y_1 = 1
        // X1 (1, 2)
        R1CSVerifier.G1Point memory Y_1 = R1CSVerifier.G1Point({
            X: uint256(1),
            Y: uint256(2)
        });

        // encrypted : Y_2 = 1
        // B2 ((10857046999023057135944570762232829481370756359578518086990519993285655852781, 11559732032986387107991004021392285783925812861821192530917403151452391805634), (8495653923123431417604973247489272438418190587263600148770280649306958101930, 4082367875863433681332203403145435568316851327593401208105741076214120093531))
        R1CSVerifier.G2Point memory Y_2 = R1CSVerifier.G2Point({
            X: [
                uint256(11559732032986387107991004021392285783925812861821192530917403151452391805634),
                uint256(10857046999023057135944570762232829481370756359578518086990519993285655852781)
            ],
            Y: [
                uint256(4082367875863433681332203403145435568316851327593401208105741076214120093531),
                uint256(8495653923123431417604973247489272438418190587263600148770280649306958101930)
            ]
        });

        // encrypted : V2_1 = 1
        // X1 (1, 2)
        R1CSVerifier.G1Point memory V2_1 = R1CSVerifier.G1Point({
            X: uint256(1),
            Y: uint256(2)
        });

        bool isVerified = verifier.verify_two(Y_1, Y_2, V2_1);
        assertEq(isVerified, true);

    }
}