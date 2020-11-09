// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../IRewardModel.sol";


contract WinnerTakesAllModelL is IRewardModelL{
    
    string constant NAME = "Winner-Takes-All Reward Model";
    
    
    function getName() external view override returns (string memory){
        return NAME;
    }
    
    
    function calcContributorRewards(uint256 _totalAmount, VotesL.Vote[] calldata _votes) external override{
        
        
    }

    function calcVoterRewards(uint256 _totalAmount, VotesL.Vote[] calldata _votes) external override{
        
    }
    
    
}