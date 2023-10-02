//SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

// import {console2} from "@forge-std/console2.sol";
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

        // ECOperations.ECPoint memory point = ECOperations.ECPoint({
        //     x: 1,
        //     y: 2
        // });

        // ec.rationalAdd(point, point);

        vm.stopPrank();
    }
}