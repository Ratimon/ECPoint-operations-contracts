//SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {Test, stdError} from "@forge-std/Test.sol";

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

        // To get the value: (x, y). run:
        // poetry run pytest
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

    function test_matMul() external {

    }
}