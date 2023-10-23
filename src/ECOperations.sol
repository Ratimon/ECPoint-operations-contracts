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
    function matMul(
        uint256[] calldata matrix,
        uint256 n, // n x n for the matrix
        ECPoint[] calldata s, // n elements
        ECPoint[] calldata o // n elements
       ) public view returns (bool verified) {

        // revert if dimensions don't make sense or the matrices are empty
        require(matrix.length == n*n, "matrix length does not match");

        uint256 matrixCounter = 0;

        ECPoint[] memory sumPoints = new ECPoint[](n);

        for (uint256 i = 0; i < n; i++) {

            uint256[3] memory mulInput;
            ECPoint memory mulResult;
            ECPoint[] memory cachedPoints = new ECPoint[](n);

            for (uint256 j = 0; j < n; j++) {

                mulInput[0] = s[j].x;
                mulInput[1] = s[j].y;
                mulInput[2] = matrix[matrixCounter];

                assembly {
                    verified := staticcall(sub(gas(), 2000), 7, mulInput, 0x80, mulResult, 0x60)
                    switch verified case 0 { invalid() }
                }

                require(verified, "multiply-failed");

                cachedPoints[j].x = mulResult.x;
                cachedPoints[j].y = mulResult.y;

                matrixCounter++;
            }

            uint256[4] memory addInput;
            ECPoint memory cachedSum = cachedPoints[0];
           
            // k = 0
            for (uint256 k = 0; k < n-1; k++) {
                
                addInput[0] = cachedSum.x;
                addInput[1] = cachedSum.y;
                addInput[2] = cachedPoints[k+1].x;
                addInput[3] = cachedPoints[k+1].y;

                assembly {
                    verified := staticcall(sub(gas(), 2000), 6, addInput, 0xc0, cachedSum, 0x60)
                    switch verified case 0 { invalid() }
                }

                require(verified, "add-failed");

            }

            sumPoints[i] = cachedSum;

        }

        require(sumPoints.length == n, "sumPoints length does not match");

        for (uint256 l = 0; l < n; l++) {
            // return true if Ms == 0 elementwise. You need to do n equality checks.
            require(sumPoints[l].x == o[l].x, "result.x does not match");
            require(sumPoints[l].y == o[l].y, "result.y does not match");

        }

        return true;
    }

}