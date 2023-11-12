//SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {Test, console2, stdError} from "@forge-std/Test.sol";
import {Groth16Verifier} from "@main/Groth16Verifier.sol";

contract Groth16VerifierTest is Test {
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

    address deployer = vm.addr(deployerPrivateKey);
    address alice = makeAddr("Alice");

    Groth16Verifier verifier;

    function setUp() public {
        vm.startPrank(deployer);

        vm.deal(deployer, 1 ether);
        vm.label(deployer, "Deployer");

        verifier = new Groth16Verifier();
        vm.label(address(verifier), "Verifier");

        vm.stopPrank();
    }

    // 1st: (1)x* (1)x + (-1)v1 = 0
    function test_verify() external {
        // test suites input are generated from
        // https://github.com/Ratimon/python-zk-math/blob/main/Groth16.ipynb

        // # Our witness vector is: [1 out x y v1 v2]
        // w  [ 1 14  1  2  3  6]

        // encrypted : A
        // AG1_x =  11875194364178893954553492401677986714866872236848400464980908770614216104904
        // AG2_y =  1745931354231226481197267507063530252187087760877187346159283447433272042416
        Groth16Verifier.G1Point memory A = Groth16Verifier.G1Point({
            X: uint256(11875194364178893954553492401677986714866872236848400464980908770614216104904),
            Y: uint256(1745931354231226481197267507063530252187087760877187346159283447433272042416)
        });

        // encrypted : B
        // BG2_x1 =  6924602501121026249589381875774890071536197581515748953207543838373963201728

        // BG2_x2 =  17669910259781833670213145246136461402469144627494348846811202205232831152317

        // BG2_y1 =  6878733559265880876009410313708957190829192504316413095644358247575366168833

        // BG2_y2 =  14121526895642396450792006482533611011995333475901619442691494720354567354807
        Groth16Verifier.G2Point memory B = Groth16Verifier.G2Point({
            X: [
                uint256(17669910259781833670213145246136461402469144627494348846811202205232831152317),
                uint256(6924602501121026249589381875774890071536197581515748953207543838373963201728)
            ],
            Y: [
                uint256(14121526895642396450792006482533611011995333475901619442691494720354567354807),
                uint256(6878733559265880876009410313708957190829192504316413095644358247575366168833)
            ]
        });

        // encrypted : C
        // CG1_x =  14301601145306053048655094763080599132319554666394446779504245502468178257858

        // CG1_y =  2660927896632112094165426621818690582616247844306821935940755268981089605284
        Groth16Verifier.G1Point memory C = Groth16Verifier.G1Point({
            X: uint256(14301601145306053048655094763080599132319554666394446779504245502468178257858),
            Y: uint256(2660927896632112094165426621818690582616247844306821935940755268981089605284)
        });

        uint256[2] memory _inputs;

        _inputs[0] = 1;
        _inputs[1] = 14;

        bool isVerified = verifier.verify(A, B, C, _inputs);
        assertEq(isVerified, true);
    }
}
