//SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {Test,console2, stdError} from "@forge-std/Test.sol";

import {Verifier} from "@main/Verifier.sol";

contract VerifierTest is Test {
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

    address deployer = vm.addr(deployerPrivateKey);
    address alice = makeAddr("Alice");

    Verifier verifier;

    function setUp() public {
        vm.startPrank(deployer);

        vm.deal(deployer, 1 ether);
        vm.label(deployer, "Deployer");

        verifier = new Verifier();
        vm.label(address(verifier), "Verifier");

        vm.stopPrank();
    }


    function test_verify() external {

        // a = - 61
        // b = 1
    
        // c = 7
        // d = 3
    
        // e = 10
        // f = 2
    
        // g = 4
        // h = 5
    

        // To get the value for test cases. run:
        // poetry run pytest tests/test_paring_verify.py

        // encrypted - A
        // e_A_negate (14960043073304393894129795755410277211446607165064567980923647220163495826045, 8311215364928706283575879525912797318003574384387294395703265103176317195920)
        Verifier.G1Point memory a = Verifier.G1Point({
            X: uint256(14960043073304393894129795755410277211446607165064567980923647220163495826045),
            Y: uint256(8311215364928706283575879525912797318003574384387294395703265103176317195920)
        });

        // encrypted B
        // e_B ((10857046999023057135944570762232829481370756359578518086990519993285655852781, 11559732032986387107991004021392285783925812861821192530917403151452391805634), (8495653923123431417604973247489272438418190587263600148770280649306958101930, 4082367875863433681332203403145435568316851327593401208105741076214120093531))
        Verifier.G2Point memory b = Verifier.G2Point({
            X: [
                uint256(11559732032986387107991004021392285783925812861821192530917403151452391805634),
                uint256(10857046999023057135944570762232829481370756359578518086990519993285655852781)
            ],
            Y: [
                uint256(4082367875863433681332203403145435568316851327593401208105741076214120093531),
                uint256(8495653923123431417604973247489272438418190587263600148770280649306958101930)
            ]
        });

        // encrypted - C
        // e_C (10415861484417082502655338383609494480414113902179649885744799961447382638712, 10196215078179488638353184030336251401353352596818396260819493263908881608606)
        Verifier.G1Point memory c = Verifier.G1Point({
            X: uint256(10415861484417082502655338383609494480414113902179649885744799961447382638712),
            Y: uint256(10196215078179488638353184030336251401353352596818396260819493263908881608606)
        });

        // encrypted - D
        // e_D ((2725019753478801796453339367788033689375851816420509565303521482350756874229, 7273165102799931111715871471550377909735733521218303035754523677688038059653), (2512659008974376214222774206987427162027254181373325676825515531566330959255, 957874124722006818841961785324909313781880061366718538693995380805373202866))
        Verifier.G2Point memory d = Verifier.G2Point({
            X: [
                uint256(7273165102799931111715871471550377909735733521218303035754523677688038059653),
                uint256(2725019753478801796453339367788033689375851816420509565303521482350756874229)
            ],
            Y: [
                uint256(957874124722006818841961785324909313781880061366718538693995380805373202866),
                uint256(2512659008974376214222774206987427162027254181373325676825515531566330959255)
            ]
        });

        // encrypted - E
        // e_E (4444740815889402603535294170722302758225367627362056425101568584910268024244, 10537263096529483164618820017164668921386457028564663708352735080900270541420)
        Verifier.G1Point memory e = Verifier.G1Point({
            X: uint256(4444740815889402603535294170722302758225367627362056425101568584910268024244),
            Y: uint256(10537263096529483164618820017164668921386457028564663708352735080900270541420)
        });

        // encrypted - F
        // e_F ((18029695676650738226693292988307914797657423701064905010927197838374790804409, 14583779054894525174450323658765874724019480979794335525732096752006891875705), (2140229616977736810657479771656733941598412651537078903776637920509952744750, 11474861747383700316476719153975578001603231366361248090558603872215261634898))
        Verifier.G2Point memory f = Verifier.G2Point({
            X: [
                uint256(14583779054894525174450323658765874724019480979794335525732096752006891875705),
                uint256(18029695676650738226693292988307914797657423701064905010927197838374790804409)
            ],
            Y: [
                uint256(11474861747383700316476719153975578001603231366361248090558603872215261634898),
                uint256(2140229616977736810657479771656733941598412651537078903776637920509952744750)
            ]
        });

        // encrypted - G
        // e_G (3010198690406615200373504922352659861758983907867017329644089018310584441462, 4027184618003122424972590350825261965929648733675738730716654005365300998076)
        Verifier.G1Point memory g = Verifier.G1Point({
            X: uint256(3010198690406615200373504922352659861758983907867017329644089018310584441462),
            Y: uint256(4027184618003122424972590350825261965929648733675738730716654005365300998076)
        });

        // encrypted - F
        // e_H ((20954117799226682825035885491234530437475518021362091509513177301640194298072, 4540444681147253467785307942530223364530218361853237193970751657229138047649), (21508930868448350162258892668132814424284302804699005394342512102884055673846, 11631839690097995216017572651900167465857396346217730511548857041925508482915))
        Verifier.G2Point memory h = Verifier.G2Point({
            X: [
                uint256(4540444681147253467785307942530223364530218361853237193970751657229138047649),
                uint256(20954117799226682825035885491234530437475518021362091509513177301640194298072)
            ],
            Y: [
                uint256(11631839690097995216017572651900167465857396346217730511548857041925508482915),
                uint256(21508930868448350162258892668132814424284302804699005394342512102884055673846)
            ]
        });

        bool isVerified = verifier.verify(a, b, c, d, e, f, g, h);

        assertEq(isVerified, true);

    }
}