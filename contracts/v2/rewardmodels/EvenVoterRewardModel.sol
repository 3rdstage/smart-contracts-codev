// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./ProportionalRewardModel.sol";


contract EvenVoterRewardModelL is ProportionalRewardModelL{
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    string private constant name = "Proportional Reward for Votee and Fixed Reward for Voter Model";
    
    function _calcVoterRewards(uint256 _totalAmt, address[] memory _topVotees, Vote[] memory _votes) 
        internal view virtual override returns(Reward[] memory voteeRewards){

        
    }
    

    
}