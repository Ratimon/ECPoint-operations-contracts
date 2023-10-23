//SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {Test,console2, stdError} from "@forge-std/Test.sol";

import {ECOperations} from "@main/ECOperations.sol";

contract ECOperationsTest is Test {
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

    address deployer = vm.addr(deployerPrivateKey);
    address alice = makeAddr("Alice");

    ECOperations ec;

    function setUp() public {
        vm.startPrank(deployer);

        vm.deal(deployer, 1 ether);
        vm.label(deployer, "Deployer");

        ec = new ECOperations();
        vm.label(address(ec), "ECOperations");

        vm.stopPrank();
    }

    function test_rationalAdd() external {
        vm.startPrank(alice);

        // To get the value: (x, y) for test cases. run:
        // poetry run pytest tests/test_add.py
        ECOperations.ECPoint memory point1 = ECOperations.ECPoint({
            x: uint256(4746413956640574926461252727128477233913017861890454231694527599705621810724),
            y: uint256(16193881401749671088058241155929092985630179886603826254428773505483197550341)
        });

        ECOperations.ECPoint memory point2 = ECOperations.ECPoint({
            x: uint256(4020592843113960083816750342797518259360106472240517742667778613682997480506),
            y: uint256(15366454237806459103088794614571810333284577576279935076483492865971729267978)
        });

        ECOperations.ECPoint memory point3 = ECOperations.ECPoint({
            x: uint256(9582769803994872715397292001384418352154900329485266669656026968603446991830),
            y: uint256(5451069605744607891896728235223195132108455436436164871752659273665438636777)
        });

        ec.rationalAdd(point1, point2, point3);

        vm.stopPrank();
    }

    function test_matMul() external view {

        // 2x + 8y = 7944
        // 5x + 3y = 4764
    
        // Known solution (known only to the prover)
        // x = 420
        // y = 888

        uint256[] memory matrix = new uint256[](4);
        matrix[0] = 2;
        matrix[1] = 8;
        matrix[2] = 5;
        matrix[3] = 3;

        // To get the value: (x, y) for test cases . run:
        // poetry run pytest tests/test_matrix_mul.py
        ECOperations.ECPoint[] memory s = new ECOperations.ECPoint[](2);
        // encrypted x
        s[0] = ECOperations.ECPoint({
            x: uint256(14272123054654457709936604042122767711746368495379248511670154852957621272879),
            y: uint256(5390793356463663377023184148570679692566494850099183968889446432602329490088)
        });
        // encrypted y
        s[1] = ECOperations.ECPoint({
            x: uint256(16760028444954030715126837513142897443651137261182029666892102559655800691858),
            y: uint256(12495712043539181555106178299219046652619546681353186672747926470895059430081)
        });

        ECOperations.ECPoint[] memory o = new ECOperations.ECPoint[](2);

        // encrypted public value 1 (2x + 8y = 7944)
        o[0] = ECOperations.ECPoint({
            x: uint256(7757279648308878215836488252689090467101377130260313290204625474069337732825),
            y: uint256(4624815465799577881298086553487173444342537614138234158000905409423691879147)
        });

        // encrypted public value 1  (5x + 3y = 4764)
        o[1] = ECOperations.ECPoint({
            x: uint256(16589555354478738665653818189207798234004106182069212202332433305931359753608),
            y: uint256(11859774485116223636876532794734439163672571181290517648884358945579572799746)
        });

        ec.matMul(matrix, 2, s, o);

    }
}