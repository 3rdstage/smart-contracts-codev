// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../IRewardModel.sol";


contract Only2VoteesAllowedModelL is IRewardModelL{
    
    string constant NAME = "Only 2 Votees Allowed Reward Model";
    
    //@TODO remove later
    event VoteIdentified(address voter, address votee, uint256 amt);
    
    function getName() external view override returns (string memory){
        return NAME;
    }

    function calcContributorRewards(uint256 _totalAmount, Vote[] calldata _votes) 
        external view override returns (Reward[] memory voterRewards, Reward[] memory voteeRewards){
            
        uint256 l = _votes.length;
        require(l > 0, "Only2VoteesAllowedModel: The provided vote data is empty.");

    }

    function calcVoterRewards(uint256 _totalAmount, Vote[] calldata _votes) 
        external view override returns (Reward[] memory voterRewards, Reward[] memory voteeRewards){
        
    }


    
}