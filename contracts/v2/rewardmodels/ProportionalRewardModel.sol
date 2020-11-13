// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../IRewardModel.sol";


contract ProportionalRewardModelL is IRewardModelL{
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    string private constant name = "Proportionally rewarded model";
    
    uint256 private immutable voterHighPortion;
    
    uint256 private immutable voterBasePortion;
    
    function getName() external view override returns (string memory){
        return name;
    }
    
    constructor(uint8 _vtrHighPort, uint8 _vtrBasePort) public {
        require(_vtrHighPort >= _vtrBasePort, "ProportionalRewardModel: High portion should be equal or greater than base portion");
        
        voterHighPortion = _vtrHighPort;
        voterBasePortion = _vtrBasePort;
    }

    function calcRewards(RewardPot calldata _rewardPot, Vote[] calldata _votes, Score[] calldata _scores) 
        external view override virtual returns (Reward[] memory voteeRewards, Reward[] memory voterRewards, uint256 remainder){
        
        require(_scores.length > 0, "ProportionalRewardModel: The specified votee scores are empty.");
        require(_votes.length > 0, "ProportionalRewardModel: The speified votes are empty.");
        
        uint256 ttl = _rewardPot.total;
        uint8 cntrbsPrct = _rewardPot.contribsPercent;
        require(ttl > 0, "ProportionalRewardModel: The specified total reward is ZERO.");
        require(cntrbsPrct > 0 && cntrbsPrct < 100, "ProportionalRewardModel: The percentage for contributors should be between 0 and 100 exclusively.");

        // calculate votees' rewards first based on scores
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

            assert(topVtees.length > 0);         // should be guaranteed internally
        }

        uint256 vterTotal = ttl.sub(vteeTotal);  // total reward amount for voters
        Vote[] memory vts = _votes;              // local copy to avoid 'stack too deep'
        
        // calc voters' rewards
        voterRewards = _calcVoterRewards(vterTotal, topVtees, vts);
        
        // calc remainder
        remainder = _calcRemainder(ttl, voteeRewards, voterRewards);
    }
    
    
    function _calcVoterRewards(uint256 _totalAmt, address[] memory _topVotees, Vote[] memory _votes) 
        internal virtual view returns(Reward[] memory voteeRewards){   // `view` visibility for derived contracts
        
        uint256 k = _topVotees.length;               // number of top ranked votees
        require(k > 0, "ProportionalRewardModel: Top ranked votees should be at least one.");
        
        // determine voters' portions - voted to top ranker(s) : 15, otherwise : 10
        uint256 m = _votes.length;                     // number of voters
        uint256[] memory vtrPrts = new uint256[](m);   // voter portions - indexed by the position in `_votes` param
        {                                              // block to avoid 'stack too deep'
            address curVtee;                           // current votee address under iteration
            for(uint256 i = 0; i < m; i++){
                vtrPrts[i] = voterBasePortion;         // set base portion first
                curVtee = _votes[i].votee;
                for(uint256 j = 0; j < k; j++){        // iterate over top rankers (top votees)
                    if(_topVotees[j] == curVtee){      // if the current vote hit the one of the top rankers
                        vtrPrts[i] = voterHighPortion; // update voter's portion to high portion
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
    
    function _calcRemainder(uint256 _totalRwd, Reward[] memory _vteeRwds, Reward[] memory _vterRwds) 
        internal pure returns (uint256){
        
        uint256 rmder = _totalRwd;
        uint256 l = _vteeRwds.length;   // votees number
        for(uint256 i = 0; i < l; i++) rmder = rmder.sub(_vteeRwds[i].amount);

        l = _vterRwds.length;            // voters number
        for(uint256 i = 0; i < l; i++) rmder = rmder.sub(_vterRwds[i].amount);

        return rmder;
    }

}