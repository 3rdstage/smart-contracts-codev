// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../IRewardModelL.sol";


contract BasicRewardModelL is IRewardModelL{
    
    
    function calcContributorRewards(uint256 totalAmount, VotesL.Vote[] calldata votes) external view override{
        
        
    }

    function calcVoterRewards(uint256 totalAmount, VotesL.Vote[] calldata votes) external view override{
        
    }
    
    
}