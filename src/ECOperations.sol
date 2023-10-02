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
     * @return  true if the prover knows two numbers that add up to num/den
     *
     */
    function rationalAdd(ECPoint calldata A, ECPoint calldata B, uint256 num, uint256 den) public view returns (bool verified) {
        
    }

}