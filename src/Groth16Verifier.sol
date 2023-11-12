//SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

/**
 * @notice Groth16 Verifier
 */
contract Groth16Verifier {
    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    struct VerifierKey {
        G1Point alpha;
        G2Point beta;
        G2Point gamma;
        G2Point delta;
        G1Point IC0;
        G1Point IC1;
    }

    function verifierKey() public pure returns (VerifierKey memory vk) {
        // test suites input are generated from
        // https://github.com/Ratimon/python-zk-math/blob/main/Groth16.ipynb

        vk = VerifierKey(
            // alpha
            G1Point({
                X: uint256(1368015179489954701390400359078579693043519447331113978918064868415326638035),
                Y: uint256(9918110051302171585080402603319702774565515993150576347155970296011118125764)
            }),
            // beta
            G2Point({
                X: [
                    uint256(7273165102799931111715871471550377909735733521218303035754523677688038059653),
                    uint256(2725019753478801796453339367788033689375851816420509565303521482350756874229)
                ],
                Y: [
                    uint256(957874124722006818841961785324909313781880061366718538693995380805373202866),
                    uint256(2512659008974376214222774206987427162027254181373325676825515531566330959255)
                ]
            }),
            // gamma
            G2Point({
                X: [
                    uint256(18556147586753789634670778212244811446448229326945855846642767021074501673839),
                    uint256(18936818173480011669507163011118288089468827259971823710084038754632518263340)
                ],
                Y: [
                    uint256(13775476761357503446238925910346030822904460488609979964814810757616608848118),
                    uint256(18825831177813899069786213865729385895767511805925522466244528695074736584695)
                ]
            }),
            // delta
            G2Point({
                X: [
                    uint256(4540444681147253467785307942530223364530218361853237193970751657229138047649),
                    uint256(20954117799226682825035885491234530437475518021362091509513177301640194298072)
                ],
                Y: [
                    uint256(11631839690097995216017572651900167465857396346217730511548857041925508482915),
                    uint256(21508930868448350162258892668132814424284302804699005394342512102884055673846)
                ]
            }),
            // IC0
            G1Point({
                X: uint256(318167186849471535662971123381928848992918484279160962473821020970098416642),
                Y: uint256(16076836094198975323910245977538090909295500755822309989577102470481140614711)
            }),
            // IC1
            G1Point({
                X: uint256(699324022537724165523498655509381022810558214871641884576111966309342930618),
                Y: uint256(3424164383113413334993935541882813701580442912882908702320518499266625600658)
            })
        );
    }

    function verify(G1Point memory A, G2Point memory B, G1Point memory C, uint256[2] memory input)
        external
        view
        returns (bool)
    {
        VerifierKey memory vk = verifierKey();

        G1Point memory k1 = scalar_mul(vk.IC0, input[0]);
        G1Point memory k2 = scalar_mul(vk.IC1, input[1]);
        G1Point memory K = plus(k1, k2);

        // -A * B + alpha * beta + C * delta + K * gamma = 0
        return pairingProd4(negate(A), B, vk.alpha, vk.beta, C, vk.delta, K, vk.gamma);
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
            case 0 { invalid() }
        }
        require(success, "pairing-opcode-failed");
        return out[0] != 0;
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

    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    /// @return the generator of G1
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }

    /// @return the generator of G2
    function P2() internal pure returns (G2Point memory) {
        // Original code point
        return G2Point(
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
    function plus(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;

        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            switch success
            case 0 { invalid() }
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
            switch success
            case 0 { invalid() }
        }
        require(success, "pairing-mul-failed");
    }
}
