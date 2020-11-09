// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../IRewardModel.sol";
import "./SampleEngine.sol";

contract SampleL{
    
    SampleEngineL private engine;

    event VoteIdentified(address voter, address votee, uint256 amount);
    
    constructor() public{
    
        engine = new SampleEngineL();
    }

    function testStructArrayParam(VotesL.Vote[] calldata _votes) external{
        uint256 l = _votes.length;
        VotesL.Vote memory vt;
        for(uint256 i = 0; i < l; i++){
            vt = _votes[i];
            emit VoteIdentified(vt.voter, vt.votee, vt.amount);
        }
    }
    
    function testStructArrayReturn(address _voter, address _votee, uint256 _amt) external pure returns(VotesL.Vote[] memory){
        
        VotesL.Vote[] memory vts = new VotesL.Vote[](2);
        vts[0] = VotesL.Vote(_voter, _votee, _amt);
        vts[1] = VotesL.Vote(_voter, _votee, _amt);
        
        return vts;
    }

    function testCallOtherContractWithStructArrayParam(uint256 _total, address[2] calldata _voter, address[2] calldata _votee) external{
        
        VotesL.Vote[] memory vts = new VotesL.Vote[](2);
        vts[0] = VotesL.Vote(_voter[0], _votee[0], 3000000000);
        vts[1] = VotesL.Vote(_voter[1], _votee[1], 4000000000);
        
        engine.calcRewards(_total, vts);
    }
    
    function testDeliverStructArrayParam(uint256 _total, VotesL.Vote[] calldata _votes) external{
        
        engine.calcRewards(_total, _votes);
    }
    
    
    
    
    
}