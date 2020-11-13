// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./ProportionalRewardModel.sol";


contract EvenVoterRewardModelL is ProportionalRewardModelL(1, 1){
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    string private constant name = "Proportional rewards for votees and even rewards for voters";


    function calcRewards(RewardPot calldata _rewardPot, Vote[] calldata _votes, Score[] calldata _scores) 
        external view override virtual returns (Reward[] memory voterRewards, Reward[] memory voteeRewards, uint256 remainder){
    
        if(true){ revert("Not yet implemented."); }
        //@TODO implement later
        
        voteeRewards = new Reward[](_scores.length);
        voterRewards = new Reward[](_votes.length);
        remainder = _rewardPot.total;
    }
    
//    function _calcVoterReward(uint256 _totalAmt, Vote[] calldata _votes) 
//        internal virtual view returns(Reward[] memory voteeRewards){
//    
//    }
        

    
}