//SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

/**
 * @notice leverages the precompiles
 */
contract R1CSVerifier {

    struct G1Point {
        uint256 X;
        uint256 Y;
      }
    
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    // 5 constraints & parings
    // 1st: x*x - v1 = 0
    // 2nd: y*y - v2 = 0
    // 3rd: v1*v2 - v3 = 0
    // 4th: x*v2 - v4 = 0
    // 5th: (5*v1)*x - out - 10*y + v1 - 4*v3 + 13*v4 = 0

    // 1st: (1)x* (1)x + (-1)v1 = 0
    uint256 l1 = 1;
    uint256 r1 = 1;
    uint256 o1 = 1;

    // 2nd: (1)y* (1)y + (-1)v2 = 0
    uint256 l2 = 1;
    uint256 r2 = 1;
    uint256 o2 = 1;

    // 3rd: (1)v1* (1)v2 + (-1)v3 = 0
    uint256 l3 = 1;
    uint256 r3 = 1;
    uint256 o3 = 1;

    // 4th: (1)x* (1)v2 + (-1)v4 = 0
    uint256 l4 = 1;
    uint256 r4 = 1;
    uint256 o4 = 1;

    // 5th: (5)v1* (1)x + (-1)out + (-10)*y + (1)v1 + (-4)*v3 + (13)*v4  = 0
    uint256 l5 = 5;
    uint256 r5 = 1;
    uint256 o5_1 = 1;
    uint256 o5_2 = 10;
    uint256 o5_3 = 1;
    uint256 o5_4 = 4;
    uint256 o5_5 = 13;

    // Our witness vector is: [1 out x y v1 v2 v3 v4]

    // 1st: (1)x* (1)x + (-1)v1 = 0
    function verify_one(
        G1Point memory X_1,
        G2Point memory X_2,
        G1Point memory V1_1
    ) external view returns (bool) {

        return pairingProd2(
            scalar_mul(X_1, l1*r1),
            X_2,
            negate(scalar_mul(V1_1, o1)),
            P2()
        );

    }

    // 2nd: (1)y* (1)y + (-1)v2 = 0
    function verify_two(
        G1Point memory Y_1,
        G2Point memory Y_2,
        G1Point memory V2_1
    ) external view returns (bool) {

        return pairingProd2(
            scalar_mul(Y_1, l2*r2),
            Y_2,
            negate(scalar_mul(V2_1, o2)),
            P2()
        );
    }

    // 3rd: (1)v1* (1)v2 + (-1)v3 = 0
    function verify_three(
        G1Point memory V1_1,
        G2Point memory V2_2,
        G1Point memory V3_1
    ) external view returns (bool) {

        return pairingProd2(
            scalar_mul(V1_1, l3*r3),
            V2_2,
            negate(scalar_mul(V3_1, o3)),
            P2()
        );
    }

    // 4th: (1)x* (1)v2 + (-1)v4 = 0
    function verify_four(
        G1Point memory X_1,
        G2Point memory V2_2,
        G1Point memory V4_1
    ) external view returns (bool) {

        return pairingProd2(
            scalar_mul(X_1, l4*r4),
            V2_2,
            negate(scalar_mul(V4_1, o4)),
            P2()
        );
    }

    // 5th: (5)v1* (1)x + (-1)out + (-10)*y + (2)v1 + (-4)*v3 + (13)*v4  = 0
    function verify_five(
        G1Point memory V1_1,
        G2Point memory X_2,
        G1Point memory OUT_1,
        G1Point memory Y_1,
        G1Point memory V3_1,
        G1Point memory V4_1
    ) external view returns (bool) {

        return pairingProd6(
            // (5)v1* (1)x
            scalar_mul(V1_1, l5*r5),
            X_2,
            // (-1)out
            negate(scalar_mul(OUT_1, o5_1)),
            P2(),
            // (-10)*y
            negate(scalar_mul(Y_1, o5_2)),
            P2(),
            // (1)v1
            scalar_mul(V1_1, o5_3),
            P2(),
            // (-4)*v3
            negate(scalar_mul(V3_1, o5_4)),
            P2(),
            // (13)*v4
            scalar_mul(V4_1, o5_5),
            P2()
        );
    }


    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length, "pairing-lengths-failed");
        uint256 elements = p1.length;
        uint256 inputSize = elements * 6;
        uint256[] memory input = new uint256[](inputSize);
        for (uint256 i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint256[1] memory out;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success
                case 0 {
                    invalid()
                }
        }
        require(success, "pairing-opcode-failed");
        return out[0] != 0;
    }

    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }

    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }

    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
    

    /// Convenience method for a pairing check for six pairs.
    function pairingProd6(
            G1Point memory a1,
            G2Point memory a2,
            G1Point memory b1,
            G2Point memory b2,
            G1Point memory c1,
            G2Point memory c2,
            G1Point memory d1,
            G2Point memory d2,
            G1Point memory e1,
            G2Point memory e2,
            G1Point memory f1,
            G2Point memory f2
        ) internal view returns (bool) {
            G1Point[] memory p1 = new G1Point[](6);
            G2Point[] memory p2 = new G2Point[](6);
            p1[0] = a1;
            p1[1] = b1;
            p1[2] = c1;
            p1[3] = d1;
            p1[4] = e1;
            p1[5] = f1;

            p2[0] = a2;
            p2[1] = b2;
            p2[2] = c2;
            p2[3] = d2;
            p2[4] = e2;
            p2[5] = f2;
            return pairing(p1, p2);
        }

    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    /// @return the generator of G1
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }

    /// @return the generator of G2
    function P2() internal pure returns (G2Point memory) {
        // Original code point
        return
            G2Point(
                [
                    11559732032986387107991004021392285783925812861821192530917403151452391805634,
                    10857046999023057135944570762232829481370756359578518086990519993285655852781
                ],
                [
                    4082367875863433681332203403145435568316851327593401208105741076214120093531,
                    8495653923123431417604973247489272438418190587263600148770280649306958101930
                ]
            );

    }

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