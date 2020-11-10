// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../IRewardModel.sol";


contract Top2RewardedModelL is IRewardModelL{
    
    string private constant name = "Top 2 Rewarded Model";
    
    
    function getName() external view override returns (string memory){
        return name;
    }
    
    
    function calcContributorRewards(RewardPot calldata _rewardPot, Vote[] calldata _votes, Score[] calldata _scores) 
        external view override returns (Reward[] memory voterRewards, Reward[] memory voteeRewards){

    }

    function calcVoterRewards(uint256 _totalAmount, Vote[] calldata _votes) 
        external view override returns (Reward[] memory voterRewards, Reward[] memory voteeRewards){
        
    }
    
    
}