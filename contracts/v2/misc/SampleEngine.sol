// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../IRewardModel.sol";

contract SampleEngineL{
    

    event VoteAccepted(address voter, address votee, uint256 amount);
    
    function calcRewards(uint256 _total, Vote[] calldata _votes) external{
        uint256 l = _votes.length;
        Vote memory vt;
        for(uint256 i = 0; i < l; i++){
            vt = _votes[i];
            emit VoteAccepted(vt.voter, vt.votee, vt.amount);
        }        
    }
}