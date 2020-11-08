// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./IRewardModel.sol";

contract ProjectL is Ownable{
    using EnumerableSet for EnumerableSet.AddressSet;

    struct RewardPlan{
        uint256 total;
        uint8 contributorsPercent;  // (0, 100)
    }
    
    uint256 private id;

    string private name;
    
    IRewardModelL private rewardModel;

    RewardPlan rewardPlan;

    bool private rewarded = false;   // whether or not rewards are distributed to contributors and voters
    
    EnumerableSet.AddressSet private voters;
    
    event RewardPlanUpdated(uint256 indexed projectId, uint256 totalReward, uint8 contributorsPercent);
    
    event RewardDistributed(uint256 indexed projectId);
    
    constructor(uint256 _id, string memory _name) public{
        id = _id;
        name = _name;
    }
  
    function getId() external view returns (uint256){
        return id;
    }
    
    function getName() external view returns (string memory){
        return name;
    }
    
    function setRewardPlan(uint256 total, uint8 contribPerct) external{
        require(contribPerct > 0 && contribPerct < 100, "The percentage for contributors should be between 0 and 100 exclusively.");
        require(!rewarded, "Reward plan can't be changed after rewards are distributed. - This project has been rewareded already.");
        
        rewardPlan = RewardPlan(total, contribPerct); 
        emit RewardPlanUpdated(id, total, contribPerct);
    }
    
    function getRewardPlan() external view returns (uint256 total, uint8 conbribPerct){
        return (rewardPlan.total, rewardPlan.contributorsPercent);
    }
    
    function setRewarded() external{
        rewarded = true;
        emit RewardDistributed(id);
    }

    function isRewarded() external view returns (bool){
        return rewarded;
    }    

    function assignVoters(address[] calldata _voters) external{
        
        uint256 l = voters.length();
        
        for(uint256 i = l; i > 0; i--){
            voters.remove(voters.at(i - 1));
        }
        
        for(uint i = 0; i < _voters.length; i++){
            voters.add(_voters[i]);
        }
    }
    
    // will retrun empty array at initial state
    function getVoters() external view returns (address[] memory){
        uint256 l = voters.length();
        address[] memory _voters = new address[](l);
        
        for(uint256 i = 0; i < l; i++){
            _voters[i] = voters.at(i);
        }
        return _voters;
    }
    
    function hasVoter(address _voter) external view returns (bool){
        return voters.contains(_voter);
    }

}
