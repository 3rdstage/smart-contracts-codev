// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./AbstractRewardModel.sol";


contract Top2RewardedModelL is AbstractRewardModelL{
    
    string private constant name = "Top 2 voters are rewarded model";

    function getName() external view override returns (string memory){
        return name;
    }

    function calcRewards(RewardPot calldata _rewardPot, Vote[] calldata _votes, Score[] calldata _scores, uint256 _floorAt) 
        external view override virtual returns (Reward[] memory voterRewards, Reward[] memory voteeRewards, uint256 remainder){
    
        bool impled;
        if(impled){ revert("Not yet implemented."); }
        //@TODO implement later
        
        voteeRewards = new Reward[](_scores.length);
        voterRewards = new Reward[](_votes.length);
        remainder = _rewardPot.total;
    }
}