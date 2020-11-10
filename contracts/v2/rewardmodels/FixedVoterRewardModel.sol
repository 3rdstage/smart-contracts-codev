// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./ProportionalRewardModel.sol";


contract FixedVoterRewardModelL is ProportionalRewardModelL{
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    string private constant name = "Proportional Reward for Votee and Fixed Reward for Voter Model";
    
    uint256 private voterReward;   // fixed reward for voter

    constructor(uint256 _voterRwd) public{
        voterReward = _voterRwd;
    }

    
    function _calcVoterRewards(uint256 _totalAmt, address[] memory _topVotees, Vote[] memory _votes) 
        internal view virtual override returns(Reward[] memory voteeRewards){

        uint256 m = _votes.length; // number of voters

        voteeRewards = new Reward[](m);
        for(uint256 i = 0; i < m; i++){
            voteeRewards[i] = Reward(_votes[i].voter, voterReward);
        }
        
    }
    

    
}