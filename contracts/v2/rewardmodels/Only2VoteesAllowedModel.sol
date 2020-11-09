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
    
    
    function calcContributorRewards(uint256 _totalAmount, VotesL.Vote[] calldata _votes) external override{
        
        uint256 l = _votes.length;
        VotesL.Vote memory vt;
        for(uint256 i = 0; i < l; i++){
            vt = _votes[i];
            emit VoteIdentified(vt.voter, vt.votee, vt.amount);
            
        }
        
    }

    function calcVoterRewards(uint256 _totalAmount, VotesL.Vote[] calldata _votes) external override{
        
    }

    function testStructArrayParams(VotesL.Vote[] calldata _votes) external{
        
        uint256 l = _votes.length;
        VotesL.Vote memory vt;
        for(uint256 i = 0; i < l; i++){
            vt = _votes[i];
            emit VoteIdentified(vt.voter, vt.votee, vt.amount);
            
        }
        
        
    }

    
}