//SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

/**
 * @notice leverages the precompiles
 */
contract SimpleVerifier {

    struct G1Point {
        uint256 X;
        uint256 Y;
      }
    
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    // 0 = − A B + α β + X γ + C δ
    // where X = 2 x G1 + 3 x G1 + 5 x G1

    // 3 * 27 = 2 * 10 + 7 * 3 + (2 + 3 + 5) * 2 + 4 * 5
    // 0 = - 61 * 1 + 7 * 3 + (2 + 3 + 5) * 2 + 4 * 5

    // A1 = 61
    // B2 = 1

    // α1 = 7
    // β2 = 3

    // X1 = 10
    // γ2 = 2

    // C1 = 4
    // δ2 = 5

    struct Constraints{
        G1Point alfa1;
        G2Point beta2;
        G2Point gamma2;
        G2Point delta2;
    }

    // To get the value for test cases. run:
    // poetry run pytest tests/test_paring_verify.py

    function constraints() internal pure returns (Constraints memory cs) {
        // e_B1 or α1 (10415861484417082502655338383609494480414113902179649885744799961447382638712, 10196215078179488638353184030336251401353352596818396260819493263908881608606)
        cs.alfa1 = G1Point({
            X: uint256(10415861484417082502655338383609494480414113902179649885744799961447382638712),
            Y: uint256(10196215078179488638353184030336251401353352596818396260819493263908881608606)
        });
        // e_B2 or β2 ((2725019753478801796453339367788033689375851816420509565303521482350756874229, 7273165102799931111715871471550377909735733521218303035754523677688038059653), (2512659008974376214222774206987427162027254181373325676825515531566330959255, 957874124722006818841961785324909313781880061366718538693995380805373202866))
        cs.beta2 = G2Point({
            X: [
                uint256(7273165102799931111715871471550377909735733521218303035754523677688038059653),
                uint256(2725019753478801796453339367788033689375851816420509565303521482350756874229)
            ],
            Y: [
                uint256(957874124722006818841961785324909313781880061366718538693995380805373202866),
                uint256(2512659008974376214222774206987427162027254181373325676825515531566330959255)
            ]
        });
        // e_C2 or γ2 ((18029695676650738226693292988307914797657423701064905010927197838374790804409, 14583779054894525174450323658765874724019480979794335525732096752006891875705), (2140229616977736810657479771656733941598412651537078903776637920509952744750, 11474861747383700316476719153975578001603231366361248090558603872215261634898))
        cs.gamma2 = G2Point({
            X: [
                uint256(14583779054894525174450323658765874724019480979794335525732096752006891875705),
                uint256(18029695676650738226693292988307914797657423701064905010927197838374790804409)
            ],
            Y: [
                uint256(11474861747383700316476719153975578001603231366361248090558603872215261634898),
                uint256(2140229616977736810657479771656733941598412651537078903776637920509952744750)
            ]
        });
        // e_D2 or δ2 ((20954117799226682825035885491234530437475518021362091509513177301640194298072, 4540444681147253467785307942530223364530218361853237193970751657229138047649), (21508930868448350162258892668132814424284302804699005394342512102884055673846, 11631839690097995216017572651900167465857396346217730511548857041925508482915))
        cs.delta2 = G2Point({
            X: [
                uint256(4540444681147253467785307942530223364530218361853237193970751657229138047649),
                uint256(20954117799226682825035885491234530437475518021362091509513177301640194298072)
            ],
            Y: [
                uint256(11631839690097995216017572651900167465857396346217730511548857041925508482915),
                uint256(21508930868448350162258892668132814424284302804699005394342512102884055673846)
            ]
        });

    }

    // 0 = − A B + α β + X γ + C δ
    // where X = 2 x G1 + 3 x G1 + 5 x G1

    // 3 * 27 = 2 * 10 + 7 * 3 + (2 + 3 + 5) * 2 + 4 * 5
    // 0 = - 61 * 1 + 7 * 3 + (2 + 3 + 5) * 2 + 4 * 5

    function verify(
        G1Point memory A1,
        G2Point memory B2,
        G1Point memory C1,
        uint256[] memory X
    ) external view returns (bool) {

        require(X.length == 3, "X length does not match");

        Constraints memory cs = constraints();

        // identity
        G1Point memory X1 = G1Point(0, 0);
        G1Point memory Generator = G1Point(1, 2);

        for (uint256 i = 0; i < 3; i++) {
            X1 = plus(X1, scalar_mul(Generator, X[i]));
        }

        return paring(
            negate(A1),
            B2,
            cs.alfa1,
            cs.beta2,
            X1,
            cs.gamma2,
            C1,
            cs.delta2
        );

    }

    function paring(
        G1Point memory A1,
        G2Point memory A2,
        G1Point memory B1,
        G2Point memory B2,
        G1Point memory C1,
        G2Point memory C2,
        G1Point memory D1,
        G2Point memory D2
      ) public view returns (bool) {

        G1Point[4] memory P1 = [A1, B1, C1, D1];
        G2Point[4] memory P2 = [A2, B2, C2, D2];
    
        uint256 inputSize = 24;
        uint256[] memory input = new uint256[](inputSize);
    
        for (uint256 i = 0; i < 4; i++) {
          uint256 j = i * 6;
          input[j + 0] = P1[i].X;
          input[j + 1] = P1[i].Y;
          input[j + 2] = P2[i].X[0];
          input[j + 3] = P2[i].X[1];
          input[j + 4] = P2[i].Y[0];
          input[j + 5] = P2[i].Y[1];
        }
    
        uint256[1] memory out;
        bool success;
    
        assembly {
          success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
          switch success case 0 { invalid() }
        }
    
        require(success, "pairing-opcode-failed");
    
        return out[0] != 0;

    }

    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    /*
    * @return The negation of p, i.e. p.plus(p.negate()) should be zero.
    */
    function negate(G1Point memory p) internal pure returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        if (p.X == 0 && p.Y == 0) {
        return G1Point(0, 0);
        } else {
        return G1Point(p.X, PRIME_Q - (p.Y % PRIME_Q));
        }
    }
    
    /*
    * @return r the sum of two points of G1
    */
    function plus(
        G1Point memory p1,
        G1Point memory p2
    ) internal view returns (G1Point memory r) {
        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;

        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            switch success case 0 { invalid() }
        }

        require(success, "pairing-add-failed");
    }

    /*
    * @return r the product of a point on G1 and a scalar, i.e.
    *         p == p.scalar_mul(1) and p.plus(p) == p.scalar_mul(2) for all
    *         points p.
    */
    function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {
        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            switch success case 0 { invalid() }
        }
        require(success, "pairing-mul-failed");
    }

}