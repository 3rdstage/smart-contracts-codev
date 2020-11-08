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
    
    enum ProjectState{
        VoteNotStarted,      // voters can not vote yet
        VoteStarted,         // voters can vote
        VoteEnded,           // vote is finished. - all voters have voted or some voters have given up.
        Rewarded            // rewards are distributed to contributors and voters
    }
    
    Counters.Counter private projectCnter;
    
    EnumerableMap.UintToAddressMap private projects;  // Map(key: id, value: address)
    
    mapping(address => string) private rewardModels; // Map(key: address, value: name)
    
    EnumerableSet.AddressSet private rewardModelAddrs; // keys for rewardModels;

    event ProjectCreated(uint256 indexed id, address addr);

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Aadmin role is required to do this");
        _;
    }
    
    constructor() public{
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function createProject(string memory _name) public onlyAdmin{
        projectCnter.increment();
        uint256 id = projectCnter.current();
        // new project is NEVER expected to be included in the `projects` already
        assert(!projects.contains(id));
        
        ProjectL prj = new ProjectL(id, _name);
        address addr = address(prj);
        projects.set(id, addr);
        
        emit ProjectCreated(id, addr);
    }
    
    function createProject(string memory _name, uint256 totalReward, uint8 contribPrect) public onlyAdmin{
        //@TODO        
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

    
    function distrubteReward(uint256 _prjId) public onlyAdmin{
        
        // @TODO
        
        VotesL.Vote[] memory vts = new VotesL.Vote[](10);
        
        //IRewardModelL model = new I();
        
        //model.calcContributorRewards(100000000, vts);
        
    }
    
    
    
}