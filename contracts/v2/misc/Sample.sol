// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../Commons.sol";
import "./SampleEngine.sol";

contract SampleL{
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    SampleEngineL private engine;

    event VoteIdentified(address voter, address votee, uint256 amount);
    
    event VoteeRewardCalced(address votee, uint256 amount);
    event VoterRewardCalced(address voter, uint256 amount);

    event HereArrived(uint256 index, uint256 lineNo);
    event TieTopRankerCount(uint256 n);
    event TopRankerIdentified(uint256 index, address addr);
    
    
    constructor() public{
    
        engine = new SampleEngineL();
    }

    function testStructArrayParam(Vote[] calldata _votes) external{
        uint256 l = _votes.length;
        Vote memory vt;
        for(uint256 i = 0; i < l; i++){
            vt = _votes[i];
            emit VoteIdentified(vt.voter, vt.votee, vt.amount);
        }
    }
    
    function testStructArrayReturn(address _voter, address _votee, uint256 _amt) external pure returns(Vote[] memory){
        
        Vote[] memory vts = new Vote[](2);
        vts[0] = Vote(_voter, _votee, _amt);
        vts[1] = Vote(_voter, _votee, _amt);
        
        return vts;
    }

    function testCallOtherContractWithStructArrayParam(uint256 _total, address[2] calldata _voter, address[2] calldata _votee) external{
        
        Vote[] memory vts = new Vote[](2);
        vts[0] = Vote(_voter[0], _votee[0], 3000000000);
        vts[1] = Vote(_voter[1], _votee[1], 4000000000);
        
        engine.calcRewards(_total, vts);
    }
    
    function testDeliverStructArrayParam(uint256 _total, Vote[] calldata _votes) external{

        engine.calcRewards(_total, _votes);
    }
    
    function testStructParam(RewardPot calldata _rwdPot, Score calldata _scr) external pure returns (uint256 total, uint8 prct, Score memory score){
        
        total = _rwdPot.total;
        prct = _rwdPot.contribsPercent;
        score = _scr;
    }    
    
    
    function testCalcRewards(RewardPot calldata _rewardPot, Vote[] calldata _votes, Score[] calldata _scores) 
        external returns (Reward[] memory voterRewards, Reward[] memory voteeRewards){
        
        require(_scores.length > 0, "ProportionalRewardModel: The specified votee scores are empty.");
        require(_votes.length > 0, "ProportionalRewardModel: The speified votes are empty.");
        
        uint256 ttl = _rewardPot.total;
        uint8 cntrbsPrct = _rewardPot.contribsPercent;
        require(ttl > 0, "ProportionalRewardModel: The specified total reward is ZERO.");
        require(cntrbsPrct > 0 && cntrbsPrct < 100, "ProportionalRewardModel: The percentage for contributors should be between 0 and 100 exclusively.");

        emit HereArrived(1, 77);

        // calculate votee rewards first based on scores
        uint256 l = _scores.length;                        // number of votees
        uint256 vteeTotal = ttl.mul(cntrbsPrct).div(100);  // total reward amount for votees
        voteeRewards = new Reward[](l);                    // 1st output parameter
        {                                                  // block to avoid 'stack too deep'
            uint256 scrSum = 0;                            // sum of votee scores
            for(uint256 i = 0; i < l; i++) scrSum = scrSum.add(_scores[i].value);
        
            for(uint256 i = 0; i < l; i++){
                voteeRewards[i] = Reward(_scores[i].owner, vteeTotal.mul(_scores[i].value).div(scrSum));     
            }
        }
        
        emit HereArrived(2, 92);
        
        // select top ranker(s) 
        address[] memory topVtees = new address[](l);  // top scored votees - tie is possiblee
        {                                        // block to avoid 'stack too deep'
            uint256 topScr = 0;                  // top score
            uint256 curScr;                      // current score under iteration
            uint256 cnt = 0;                     // tie top ranker count
            for(uint256 i = 0; i < l; i++){
                curScr = _scores[i].value;
                if(curScr > topScr){             // new top ranker
                    topScr = curScr;
                    topVtees[0] = _scores[i].owner;
                    cnt = 1;
                }else if(curScr == topScr){      // tie top ranker
                    topVtees[cnt++] = _scores[i].owner;
                }
            }

            // leave only real top ranker(s)
            address[] memory topVtees2 = new address[](cnt);
            for(uint256 i = 0; i < cnt; i++) topVtees2[i] = topVtees[i];
            topVtees = topVtees2;

            emit TieTopRankerCount(topVtees.length);
            assert(topVtees.length > 0);         // should be guaranteed internally
        }

        uint256 vterTotal = ttl.sub(vteeTotal);  // total reward amount for voters
        Vote[] memory vts = _votes;              // local copy to avoid 'stack too deep' 
        voterRewards = _calcVoterRewards(vterTotal, topVtees, vts);
        
        for(uint256 i = 0; i < l; i++){
            emit VoteeRewardCalced(voteeRewards[i].to, voteeRewards[i].amount);
        }
        uint256 m = voterRewards.length;
        for(uint256 i = 0; i < m; i++){
            emit VoterRewardCalced(voterRewards[i].to, voterRewards[i].amount);
        }

        emit HereArrived(3, 112);
    }
    
    
    function _calcVoterRewards(uint256 _totalAmt, address[] memory _topVotees, Vote[] memory _votes) 
        internal returns(Reward[] memory voteeRewards){   
        
        uint256 k = _topVotees.length;               // number of top ranked votees
        require(k > 0, "ProportionalRewardModel: Top ranked votees should be at least one.");
        
        emit TieTopRankerCount(k);
        for(uint256 i = 0; i < k; i++) emit TopRankerIdentified(i, _topVotees[i]);
        
        // determine voters' portions - voted to top ranker(s) : 15, otherwise : 10
        uint256 m = _votes.length;                   // number of voters
        uint256[] memory vtrPrts = new uint256[](m); // voter portions - indexed by the position in `_votes` param
        {                                            // block to avoid 'stack too deep'
            address curVtee;                         // current votee address under iteration
            for(uint256 i = 0; i < m; i++){
                vtrPrts[i] = 10;                     // set base portion
                curVtee = _votes[i].votee;
                for(uint256 j = 0; j < k; j++){      // iterate over top rankers (top votees)
                    if(_topVotees[j] == curVtee){    // if the current vote hit the one of the top rankers
                        vtrPrts[i] = 15;             // update portion
                        break;
                    }
                }
            }        
        }
        
        uint256 totalWghts = 0;    // sum of voters' weights (portion x vote amount)
        for(uint256 i = 0; i < m; i++){
            totalWghts = totalWghts.add(vtrPrts[i].mul(_votes[i].amount));
        }
        
        voteeRewards = new Reward[](m);
        uint256 amt;                // reward amount for each voter under iteration
        // fianlly calculate rewards for all voters
        for(uint256 i = 0; i < m; i++){
            amt = _totalAmt.mul(_votes[i].amount).mul(vtrPrts[i]).div(totalWghts);
            voteeRewards[i] = Reward(_votes[i].voter, amt);
        }
    }
    
    function testLocalUintArray(uint256 _size, uint256 _fillups, uint256 _fillVal) external pure returns (uint256[] memory){
        require(_size >= _fillups, "Sample: array size should be equal to or greter than the number to fill.");
        require(_fillVal > 0, "Sample: Value to fill should be positive for this test.");
        
        uint256[] memory values = new uint256[](_size);
        for(uint256 i = 0; i < _fillups; i++) values[i] = _fillVal;

        return values;
    }

    function testLocalAddressArray(uint256 _size, uint256 _fillups, address _fillVal) external pure returns (address[] memory){
        require(_size >= _fillups, "Sample: array size should be equal to or greter than the number to fill.");
        require(_fillVal != address(0), "Sample: Value to fill should not be ZERO address for this test.");
        
        address[] memory values = new address[](_size);
        for(uint256 i = 0; i < _fillups; i++) values[i] = _fillVal;

        return values;
    }
    
    
    function testRevertAndEvent() external{
        emit HereArrived(1, 207);
        
        revert();
    }
    
}