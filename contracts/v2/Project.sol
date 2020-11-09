// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./IRewardModel.sol";

struct RewardScale{
    uint256 total;
    uint8 contributorsPercent;  // (0, 100)
}

contract ProjectL is Ownable{
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 private id;

    string private name;

    RewardScale rewardScale;
    
    IRewardModelL private rewardModel;

    EnumerableSet.AddressSet private voters;

    bool private rewarded = false;   // whether or not rewards are distributed to contributors and voters
    
    event RewardScaleUpdated(uint256 indexed projectId, uint256 totalReward, uint8 contributorsPercent);
    
    event RewardDistributed(uint256 indexed projectId);
    
    constructor(uint256 _id, string memory _name, uint256 _totalReward, uint8 _contribPerct, address _rewardModelAddr) public{
        id = _id;
        name = _name;
        
        _setRewardScale(_totalReward, _contribPerct);
        rewardModel = IRewardModelL(_rewardModelAddr); // @TODO
    }
  
    function getId() external view returns (uint256){
        return id;
    }
    
    function getName() external view returns (string memory){
        return name;
    }

    function _setRewardScale(uint256 _total, uint8 _contribPerct) internal{
        require(_total > 0, "Project: Total reward should be positive.");
        require(_contribPerct > 0 && _contribPerct < 100, "Project: The percentage for contributors should be between 0 and 100 exclusively.");
        require(!rewarded, "Project: Reward plan can't be changed after rewards are distributed. - This project has been rewareded already.");
        
        rewardScale = RewardScale(_total, _contribPerct); 
    }
    
    function setRewardScale(uint256 _total, uint8 _contribPerct) external onlyOwner{
        _setRewardScale(_total, _contribPerct);

        emit RewardScaleUpdated(id, _total, _contribPerct);
    }
    
    function getRewardScale() external view returns (uint256 total, uint8 conbribPerct){
        return (rewardScale.total, rewardScale.contributorsPercent);
    }
    
    function setRewardModel(address _addr) external onlyOwner{
        require(_addr != address(0), "Project: Model address can't be ZERO address.");
        require(!rewarded, "Project: Reward model can't be changed, because this project was already rewarded.");
        
        rewardModel = IRewardModelL(_addr);
    }
    
    function hasRewardModel() external view returns (bool){
        return (address(rewardModel) != address(0));
    }
    
    function getRewardModelAddress() external view returns (address){
        return address(rewardModel);
    }


    function assignVoters(address[] calldata _voters) external onlyOwner{
        uint256 l = _voters.length;
        for(uint i = 0; i < l; i++) require(_voters[i] != address(0), "Project: Voter address can't be ZERO address.");
        
        l = voters.length();
        for(uint256 i = l; i > 0; i--) voters.remove(voters.at(i - 1));

        l = _voters.length;
        for(uint i = 0; i < l; i++) voters.add(_voters[i]);
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

    function setRewarded() external onlyOwner{
        require(!rewarded, "Project: This project was already rewarded before.");
        
        rewarded = true;
        emit RewardDistributed(id);
    }

    function isRewarded() external view returns (bool){
        return rewarded;
    }    

}
