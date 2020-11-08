// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../IRewardModel.sol";


contract Only2VoteesAllowedModelL is IRewardModelL{
    
    string constant NAME = "Only 2 Votees Allowed Reward Model";
    
    
    function getName() external view override returns (string memory){
        return NAME;
    }
    
    
    function calcContributorRewards(uint256 totalAmount, VotesL.Vote[] calldata votes) external view override{
        
        
    }

    function calcVoterRewards(uint256 totalAmount, VotesL.Vote[] calldata votes) external view override{
        
    }
    
    
}