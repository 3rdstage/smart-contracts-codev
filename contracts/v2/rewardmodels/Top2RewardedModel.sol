// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../IRewardModel.sol";


contract Top2RewardedModelL is IRewardModelL{
    
    string constant NAME = "Top 2 Rewarded Model";
    
    
    function getName() external view override returns (string memory){
        return NAME;
    }
    
    
    function calcContributorRewards(uint256 _totalAmount, Vote[] calldata _votes) external override{
        
        
    }

    function calcVoterRewards(uint256 _totalAmount, Vote[] calldata _votes) external override{
        
    }
    
    
}