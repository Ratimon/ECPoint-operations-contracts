//SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

/**
 * @notice leverages the precompiles
 */
contract Verifier {

    struct G1Point {
        uint256 X;
        uint256 Y;
      }
    
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    // 3 * 27 = 2 * 10 + 7 * 3 + (2 + 3 + 5) * 2 + 4 * 5
    // 0 = - 61 * 1 + 7 * 3 + (2 + 3 + 5) * 2 + 4 * 5

    // a = 61
    // b = 1

    // c = 7
    // d = 3

    // e = 10
    // f = 2

    // g = 4
    // h = 5

    function verify(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
      ) external view returns (bool) {

        G1Point[4] memory p1 = [a1, b1, c1, d1];
        G2Point[4] memory p2 = [a2, b2, c2, d2];
    
        uint256 inputSize = 24;
        uint256[] memory input = new uint256[](inputSize);
    
        for (uint256 i = 0; i < 4; i++) {
          uint256 j = i * 6;
          input[j + 0] = p1[i].X;
          input[j + 1] = p1[i].Y;
          input[j + 2] = p2[i].X[0];
          input[j + 3] = p2[i].X[1];
          input[j + 4] = p2[i].Y[0];
          input[j + 5] = p2[i].Y[1];
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

    // /*
    // * @return The negation of p, i.e. p.plus(p.negate()) should be zero.
    // */
    // function negate(G1Point memory p) internal pure returns (G1Point memory) {
    //     // The prime q in the base field F_q for G1
    //     if (p.X == 0 && p.Y == 0) {
    //     return G1Point(0, 0);
    //     } else {
    //     return G1Point(p.X, PRIME_Q - (p.Y % PRIME_Q));
    //     }
    // }

}