// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";
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

    event ProjectCreated(uint256 indexed id, address addr, uint256 totalReward, uint8 contirbPercent, address rewardModelAddr);

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Aadmin role is required to do this");
        _;
    }
    
    constructor() public{
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function createProject(string memory _name, uint256 _totalReward, uint8 _contribPerct, address _rewardModelAddr) public onlyAdmin{
        require(rewardModelAddrs.contains(_rewardModelAddr), "ProjectManager: The specified reward model is NOT registered yet. Register a reward model before assigning it to a project.");

        projectCnter.increment();
        uint256 id = projectCnter.current();
        assert(!projects.contains(id)); // not require but assert - The project ID is managed internally.
        
        ProjectL prj = new ProjectL(id, _name, _totalReward, _contribPerct, _rewardModelAddr);
        address addr = address(prj);
        projects.set(id, addr);
        
        emit ProjectCreated(id, addr, _totalReward, _contribPerct, _rewardModelAddr);
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
    
    function setProjectRewardScale(uint256 _prjId, uint256 _total, uint8 _contribPerct) external onlyAdmin{
        ProjectL prj = _findProject(_prjId);
        
        prj.setRewardScale(_total, _contribPerct);
    }

    function assignProjectVoters(uint256 _prjId, address[] calldata _voters) external onlyAdmin{
        ProjectL prj = _findProject(_prjId);
        
        prj.assignVoters(_voters);
    }
    
    function simulateRewards(uint256 _prjId) external view{
        
    }

    function distrubteRewards(uint256 _prjId) public onlyAdmin{
        ProjectL prj = _findProject(_prjId);
        IRewardModelL model = IRewardModelL(prj.getRewardModelAddress());
        Vote[] memory vts = new Vote[](10);

        model.calcContributorRewards(100000000, vts);
        
    }

}