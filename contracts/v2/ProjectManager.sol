// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "./Commons.sol";
import "./Project.sol";
import "./Votes.sol";
import "./IRewardModel.sol";

contract ProjectManagerL is Context, AccessControl{
    using Counters for Counters.Counter;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableSet for EnumerableSet.AddressSet;
  
// Not yet used, not deleted for later use.    
//    enum ProjectState{
//        VoteNotStarted,      // voters can not vote yet
//        VoteStarted,         // voters can vote
//        VoteEnded,           // vote is finished. - all voters have voted or some voters have given up.
//        Rewarded            // rewards are distributed to contributors and voters
//    }
    
    Counters.Counter private projectCnter;
    
    EnumerableMap.UintToAddressMap private projects;  // Map(key: id, value: address)
    
    mapping(address => string) private rewardModels; // Map(key: address, value: name)
    
    EnumerableSet.AddressSet private rewardModelAddrs; // keys for rewardModels;
    
    VotesL private votesContract; // votes contract

    event ProjectCreated(uint256 indexed id, address addr, uint256 totalReward, uint8 contirbPercent, address rewardModelAddr);

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Aadmin role is required to do this");
        _;
    }
    
    constructor() public{
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    
    function setVotesContact(address _addr) public onlyAdmin{
        require(_addr != address(0), "ProjectManager: Votes contract can't be ZERO address");
        
        votesContract = VotesL(_addr);
    }

    function createProject(string memory _name, uint256 _totalReward, uint8 _contribsPerct, address _rewardModelAddr) public onlyAdmin{
        projectCnter.increment();
        uint256 id = projectCnter.current();
        
        _createProject(id, _name, _totalReward, _contribsPerct, _rewardModelAddr);
    }
    
    function createProject(uint256 _id, string memory _name, uint256 _totalReward, uint8 _contribsPerct, address _rewardModelAddr) public onlyAdmin{
        _createProject(_id, _name, _totalReward, _contribsPerct, _rewardModelAddr);    
    }
    
    function _createProject(uint256 _id, string memory _name, uint256 _totalReward, uint8 _contribsPerct, address _rewardModelAddr) internal{
        require(!projects.contains(_id), "ProjectManager: A project with the specified project ID already exisits. Try again or specify another project ID."); 
        require(rewardModelAddrs.contains(_rewardModelAddr), "ProjectManager: The specified reward model is NOT registered yet. Register a reward model before assigning it to a project.");

        ProjectL prj = new ProjectL(_id, _name, _totalReward, _contribsPerct, _rewardModelAddr);
        address addr = address(prj);
        projects.set(_id, addr);
        
        emit ProjectCreated(_id, addr, _totalReward, _contribsPerct, _rewardModelAddr);        
    }
    
    
    
    function getNumberOfProjects() public view returns (uint256){
        return projects.length();
    }
    
    //@TODO getProjectIds - getting IDs of all projects
    
    function hasProject(uint256 _prjId) public view returns (bool){
        return projects.contains(_prjId);
    }
    
    function getProjectAddress(uint256 _prjId) public view returns (address){
        require(projects.contains(_prjId), "ProjectManager: There's no project with the specified project ID.");
        
        return projects.get(_prjId);
    }

    function registerRewardModel(address _modelAddr) public onlyAdmin{
        // Expecting that reward models would not so many, at most tens of models.
        
        require(_modelAddr != address(0), "ProjectManager: Zero address can't be reward model.");
        require(!rewardModelAddrs.contains(_modelAddr), "ProjectManager: The reward model at the specified address was registered already.");
        
        IRewardModelL mdl = IRewardModelL(_modelAddr);
        string memory nm = mdl.getName();
        
        rewardModels[_modelAddr] = nm;
        rewardModelAddrs.add(_modelAddr);
    } 
    
    function getNumberOfRewardModels() public view returns (uint256){
        return rewardModelAddrs.length();
    }
    
    function getRewardModel(uint256 _index) public view returns (address addr, string memory name){
        require(_index < rewardModelAddrs.length(), "ProjectManager: Index is too large." );
        
        addr = rewardModelAddrs.at(_index);
        name = rewardModels[addr];
    }
    
    function _findProject(uint256 _prjId) internal view returns (ProjectL){
        require(projects.contains(_prjId), "ProjectManager: There's no project with the specified project ID.");
        
        return ProjectL(projects.get(_prjId));
    }

    function _setProjectRewarded(uint256 _prjId) internal onlyAdmin{
        ProjectL prj = _findProject(_prjId);
        prj.setRewarded();
    }
    
    function setProjectRewardPot(uint256 _prjId, uint256 _total, uint8 _contribsPerct) external onlyAdmin{
        ProjectL prj = _findProject(_prjId);
        
        prj.setRewardPot(_total, _contribsPerct);
    }

    function assignProjectVoters(uint256 _prjId, address[] calldata _voters) external onlyAdmin{
        ProjectL prj = _findProject(_prjId);
        
        prj.assignVoters(_voters);
    }
    
    function simulateRewards(uint256 _prjId) external view returns(Reward[] memory voterRewards, Reward[] memory voteeRewards, uint256 remainder){
        ProjectL prj = _findProject(_prjId);
        
        IRewardModelL mdl = IRewardModelL(prj.getRewardModelAddress());
        Vote[] memory vts = votesContract.getVotesByProject(_prjId);
        Score[] memory scrs = votesContract.getScoresByProject(_prjId);
        
        require(vts.length > 0, "ProjectManager: There's no votes yet for the specified project.");
        
        (uint256 ttl, uint8 prct) = prj.getRewardPot();
        RewardPot memory scl = RewardPot(ttl, prct);
        return mdl.calcRewards(scl, vts, scrs);
    }

    function distrubteRewards(uint256 _prjId) public onlyAdmin{

        
    }

}