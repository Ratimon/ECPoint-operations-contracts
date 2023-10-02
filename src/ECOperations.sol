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
    function rationalAdd(ECPoint calldata A, ECPoint calldata B, uint256 num, uint256 den) public view returns (bool verified) {
        uint256[4] memory input;
        input[0] = A.x;
        input[1] = A.y;
        input[2] = B.x;
        input[3] = B.y;
        bool success;


        ECPoint memory result;

        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, result, 0x60)
          // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
          }
      
          require(success, "add-failed");
        //   require(result == num/den, "result is not num/den");
    }





}