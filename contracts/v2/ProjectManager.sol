// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "./tokens/RegularERC20Token.sol";
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
    
    //Counters.Counter private projectCnter;           // become unused : internal generated ID -> external IDß
    
    RegularERC20TokenL private token;                  // token contract for reward
    
    EnumerableMap.UintToAddressMap private projects;   // id:address map for project contracts
    
    mapping(address => string) private rewardModels;   // address:name map for reward models
    
    EnumerableSet.AddressSet private rewardModelAddrs; // keys for reward models' map - for safe access or iteration
    
    VotesL private votesContract;                      // votes contract

    event ProjectCreated(uint256 indexed id, address addr, uint256 totalReward, uint8 contirbPercent, address rewardModelAddr);
    
    event RewardModelRegistered(address indexed addr);
    
    event TokenCollected(address indexed from, uint256 amount);

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Aadmin role is required to do this");
        _;
    }
    
    /**
     * 
     * To distribute rewards, it is neccesary to grant MINTER_ROLE of the token to this project manager contract
     * outside of this contract usually at contract deploy time.
     */
    constructor(address _tknAddr) public{
        require(_tknAddr != address(0), "ProjectManager: Token address can NOT be ZERO address.");
        token = RegularERC20TokenL(_tknAddr);    
        
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    
    function getTokenAddress() external view returns (address){
        return address(token);
    }

    function setVotesContact(address _addr) external onlyAdmin{
        require(_addr != address(0), "ProjectManager: Votes contract can't be ZERO address");
        
        votesContract = VotesL(_addr);
    }

    function createProject(uint256 _id, string memory _name, uint256 _totalReward, uint8 _contribsPerct, address _rewardModelAddr) external onlyAdmin{
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

    function getNumberOfProjects() external view returns (uint256){
        return projects.length();
    }
    
    //@TODO getProjectIds - getting IDs of all projects
    
    function hasProject(uint256 _prjId) external view returns (bool){
        return projects.contains(_prjId);
    }
    
    function getProjectAddress(uint256 _prjId) external view returns (address){
        require(projects.contains(_prjId), "ProjectManager: There's no project with the specified project ID.");
        
        return projects.get(_prjId);
    }
    
    function registerRewardModels(address[] memory _modelAddrs) external onlyAdmin{
        uint256 l = _modelAddrs.length;
        
        for(uint256 i = 0; i < l; i++){
            _registerRewardModel(_modelAddrs[i]);
        }
    }

    function registerRewardModel(address _modelAddr) external onlyAdmin{
        _registerRewardModel(_modelAddr);
    } 
    
    function _registerRewardModel(address _modelAddr) internal{
        require(_modelAddr != address(0), "ProjectManager: Zero address can't be reward model.");
        // allow re-register
        //require(!rewardModelAddrs.contains(_modelAddr), "ProjectManager: The reward model at the specified address was registered already.");
        
        IRewardModelL mdl = IRewardModelL(_modelAddr);
        string memory nm = mdl.getName();
        
        rewardModels[_modelAddr] = nm;
        rewardModelAddrs.add(_modelAddr);
        emit RewardModelRegistered(_modelAddr);
    }
    
    function getNumberOfRewardModels() external view returns (uint256){
        return rewardModelAddrs.length();
    }
    
    function getRewardModel(uint256 _index) external view returns (address addr, string memory name){
        require(_index < rewardModelAddrs.length(), "ProjectManager: Index is too large." );
        
        addr = rewardModelAddrs.at(_index);
        name = rewardModels[addr];
    }
    
    function _findProject(uint256 _prjId) internal view returns (ProjectL){
        require(projects.contains(_prjId), "ProjectManager: There's no project with the specified project ID.");
        
        return ProjectL(projects.get(_prjId));
    }

    function _setProjectRewarded(uint256 _prjId) internal{
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
    
    function getProjectVoters(uint256 _prjId) external view returns(address[] memory){
        ProjectL prj = _findProject(_prjId);
        
        return prj.getVoters();
    }
    
    
    /**
     * Try to collect token (send token to me from owner) using `transferFrom` function.
     * It would fail unless the `_owner` previously approved this project manager address as much
     * allowance as `_amt`.
     * 
     * After collecting token from a voter, as much token is approved to votes contract, 
     * in case of unvote or update vote from the same voter
     */
    function collectFrom(address _owner, uint256 _amt) external{
        // collect token from voter
        token.transferFrom(_owner, address(this), _amt);
        
        // approve as much token to votes contract, in case of unvote or update vote
        token.approve(address(votesContract), _amt);
        emit TokenCollected(_owner, _amt);
    }
    
    
    function simulateRewards(uint256 _prjId) external view returns(Reward[] memory voteeRewards, Reward[] memory voterRewards, uint256 remainder){
        return _simulateRewards(_prjId);
    }
    
    function simulateRewardsArrayRetuns(uint256 _prjId) external view 
            returns(address[] memory votees, uint256[] memory voteeRewards, address[] memory voters, uint256[] memory voterRewards, uint256 remainder){
        
        (Reward[] memory vteeRwds, Reward[] memory vterRwds, uint256 rmnd) = _simulateRewards(_prjId);
        
        uint256 l = vteeRwds.length;
        votees = new address[](l);
        voteeRewards = new uint256[](l);
        for(uint256 i = 0; i < l; i++){
            votees[i] = vteeRwds[i].to;
            voteeRewards[i] = vteeRwds[i].amount;
        }
        
        uint256 m = vterRwds.length;
        voters = new address[](m);
        voterRewards = new uint256[](m);
        for(uint256 i = 0; i < m; i++){
            voters[i] = vterRwds[i].to;
            voterRewards[i] = vterRwds[i].amount;
        }
        
        remainder = rmnd;
    }    
        
    
    function _simulateRewards(uint256 _prjId) internal view 
            returns(Reward[] memory voteeRewards, Reward[] memory voterRewards, uint256 remainder){
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