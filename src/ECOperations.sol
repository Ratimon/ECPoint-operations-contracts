//SPDX-License-Identifier: MIT
pragma solidity =0.8.20;


/**
 * @notice leverages the precompiles
 */
contract ECOperations {

    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    /**
    * @notice return true if the prover knows two numbers that add up to num/den
    */
    function rationalAdd(ECPoint calldata A, ECPoint calldata B, ECPoint calldata C) public view returns (bool verified) {
        uint256[4] memory input;
        input[0] = A.x;
        input[1] = A.y;
        input[2] = B.x;
        input[3] = B.y;

        ECPoint memory result;

        assembly {
            verified := staticcall(sub(gas(), 2000), 6, input, 0xc0, result, 0x60)
            switch verified case 0 { invalid() }
          }
      
        require(verified, "add-failed");
        require(result.x == C.x, "result.x does not match");
        require(result.y == C.y, "result.y does not match");

    }

     /**
    * @notice matrix multiplication of an n x n matrix of uint256 and a 1 x n matrix of points. It validates the claim that matrix Ms = o where o is a 1 x n matrix of uint256. s is an 1 x n matrix of elliptic cruve points
    */
    function matmul(uint256[] calldata matrix,
        uint256 n, // n x n for the matrix
        ECPoint[] calldata s, // n elements
        ECPoint[] calldata o // n elements
       ) public returns (bool verified) {

        // revert if dimensions don't make sense or the matrices are empty
        // return true if Ms == 0 elementwise. You need to do n equality checks. If you're lazy, you can hardcode n to 3, but it is suggested that you do this with a for loop 
    }


}