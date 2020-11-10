// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../IRewardModel.sol";


contract ProportionalRewardModelL is IRewardModelL{
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    string private constant name = "Proportional Rewarded Model";
    
    function getName() external view override returns (string memory){
        return name;
    }

    function calcContributorRewards(RewardPot calldata _rewardPot, Vote[] calldata _votes, Score[] calldata _scores) 
        external view override returns (Reward[] memory voterRewards, Reward[] memory voteeRewards){
        
        require(_scores.length > 0, "ProportionalRewardModel: The specified votee scores are empty.");
        require(_votes.length > 0, "ProportionalRewardModel: The speified votes are empty.");
        
        uint256 ttl = _rewardPot.total;
        uint8 cntrbsPrct = _rewardPot.contribsPercent;
        require(ttl > 0, "ProportionalRewardModel: The specified total reward is ZERO.");
        require(cntrbsPrct > 0 && cntrbsPrct < 100, "ProportionalRewardModel: The percentage for contributors should be between 0 and 100 exclusively.");

        // calculate votee rewards first based on scores
        uint256 l = _scores.length;                        // number of votees
        uint256 vteeTotal = ttl.mul(cntrbsPrct).div(100);  // total reward amount for votees
        voterRewards = new Reward[](l);                    // 1st output parameter
        {                                                  // block to avoid 'stack too deep'
            uint256 scrSum = 0;                            // sum of votee scores
            for(uint256 i = 0; i < l; i++) scrSum = scrSum.add(_scores[i].value);
        
            for(uint256 i = 0; i < l; i++){
                voterRewards[i] = Reward(_scores[i].owner, vteeTotal.mul(_scores[i].value).div(scrSum));     
            }
        }
        
        // select top ranker(s) 
        address[] memory topAddrs;               // top scored votees - tie is possiblee
        {                                        // block to avoid 'stack too deep'
            uint256 topScr = 0;                  // top score
            uint256 curScr;                      // current score under iteration
            for(uint256 i = 0; i < l; i++){
                curScr = _scores[i].value;
                if(curScr > topScr){             // new top ranker
                    delete topAddrs;
                    topAddrs[0] = _scores[i].owner;
                }else if(curScr == topScr){      // tie top ranker
                    topAddrs[topAddrs.length] = _scores[i].owner;
                }
            }
            
            assert(topAddrs.length > 0);         // should be guaranteed internally
        }

        uint256 vterTotal = ttl.sub(vteeTotal);  // total reward amount for voters
        Vote[] memory vts = _votes;              // local copy to avoid 'stack too deep' 
        voteeRewards = _calcVoterRewards(vterTotal, topAddrs, vts);
    }
    
    
    function _calcVoterRewards(uint256 _totalAmt, address[] memory _topVotees, Vote[] memory _votes) 
        internal virtual view returns(Reward[] memory voteeRewards){   // `view` visibility for derived contracts
        
        uint256 k = _topVotees.length;               // number of top ranked votees
        require(k > 0, "ProportionalRewardModel: Top ranked votees should be at least one.");
        
        // determine voters shares - voted to top ranker(s) : 15, otherwise : 10
        uint256 m = _votes.length;                   // number of voters
        uint256[] memory vtrShrs = new uint256[](m); // voter shares - indexed by the position in `_votes` param
        {                                            // block to avoid 'stack too deep'
            address curVtee;                         // current votee address under iteration

            for(uint256 i = 0; i < m; i++){
                curVtee = _votes[i].votee;
                for(uint256 j = 0; j < k; j++){
                    if(_topVotees[j] == curVtee){
                        vtrShrs[i] = 15;
                        break;
                    }
                }
                vtrShrs[i] = 10;
            }        
        }
        
        uint256 wghedShrSum = 0;    // sum of voters' shares weighted vote amount
        for(uint256 i = 0; i < m; i++){
            wghedShrSum = wghedShrSum.add(vtrShrs[i].mul(_votes[i].amount));
        }
        
        voteeRewards = new Reward[](m);
        uint256 amt;                // reward amount for each voter under iteration
        for(uint256 i = 0; i < m; i++){
            amt = _totalAmt.mul(_votes[i].amount).mul(vtrShrs[i]).div(wghedShrSum);
            voteeRewards[i] = Reward(_votes[i].voter, amt);
        }
        
    }


    function calcVoterRewards(uint256 _totalAmount, Vote[] calldata _votes) 
        external view override returns (Reward[] memory voterRewards, Reward[] memory voteeRewards){
        
    }
    

}