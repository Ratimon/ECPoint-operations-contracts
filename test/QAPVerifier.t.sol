//SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {Test, console2, stdError} from "@forge-std/Test.sol";
import {QAPVerifier} from "@main/QAPVerifier.sol";

contract QAPVerifierTest is Test {
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

    address deployer = vm.addr(deployerPrivateKey);
    address alice = makeAddr("Alice");

    QAPVerifier verifier;

    function setUp() public {
        vm.startPrank(deployer);

        vm.deal(deployer, 1 ether);
        vm.label(deployer, "Deployer");

        verifier = new QAPVerifier();
        vm.label(address(verifier), "Verifier");

        vm.stopPrank();
    }

    // 1st: (1)x* (1)x + (-1)v1 = 0
    function test_verify() external {
        // test suites input are generated from
        // https://github.com/Ratimon/python-zk-math/blob/main/R1CSToQAP.ipynb

        // # Our witness vector is: [1 out x y v1 v2]
        // w  [ 1 14  1  2  3  6]

        // encrypted : A_1
        // [A]G1 = (11366259140735937107273415282276865380482951540926504512195786673583900666831, 10160201791583891081596948422072363163025983566850313407366745662998446473858)
        QAPVerifier.G1Point memory A_1 = QAPVerifier.G1Point({
            X: uint256(11366259140735937107273415282276865380482951540926504512195786673583900666831),
            Y: uint256(10160201791583891081596948422072363163025983566850313407366745662998446473858)
        });

        // encrypted : B_2
        // [B]G2 = ((7179643365236714855883022538739496148780230561383130338052152676941932525204, 343392092133814009191799384125571704297727533257021865546481423508663648796), (16011366720915142681651677129254468778345777024474729001862176517339742278864, 16533306405944982620130830869513489262198480382059124175673041200057360654730))
        QAPVerifier.G2Point memory B_2 = QAPVerifier.G2Point({
            X: [
                uint256(343392092133814009191799384125571704297727533257021865546481423508663648796),
                uint256(7179643365236714855883022538739496148780230561383130338052152676941932525204)
            ],
            Y: [
                uint256(16533306405944982620130830869513489262198480382059124175673041200057360654730),
                uint256(16011366720915142681651677129254468778345777024474729001862176517339742278864)
            ]
        });

        // encrypted : C_1
        // [C]G1 = (10155307989187883841675238365379655853722800134109175962322606340821385237561, 1243535631026526393087863318195418268521169537894907740846413512028847817544)
        QAPVerifier.G1Point memory C_1 = QAPVerifier.G1Point({
            X: uint256(10155307989187883841675238365379655853722800134109175962322606340821385237561),
            Y: uint256(1243535631026526393087863318195418268521169537894907740846413512028847817544)
        });

        bool isVerified = verifier.verify(A_1, B_2, C_1);
        assertEq(isVerified, true);
    }
}
