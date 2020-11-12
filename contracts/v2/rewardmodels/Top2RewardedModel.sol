// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


import "../IRewardModel.sol";


contract Top2RewardedModelL is IRewardModelL{
    
    string private constant name = "Top 2 voters are rewarded model";
    
    
    function getName() external view override returns (string memory){
        return name;
    }
    
    
    function calcRewards(RewardPot calldata _rewardPot, Vote[] calldata _votes, Score[] calldata _scores) 
        external view override virtual returns (Reward[] memory voterRewards, Reward[] memory voteeRewards, uint256 remainder){
    
        if(true){ revert("Not yet implemented."); }
        //@TODO implement later
        
        voteeRewards = new Reward[](_scores.length);
        voterRewards = new Reward[](_votes.length);
        remainder = _rewardPot.total;
    }
    
    
}