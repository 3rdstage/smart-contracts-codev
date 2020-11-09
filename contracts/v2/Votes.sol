// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "./ProjectManager.sol";
import "./Project.sol";
import "./Contributions.sol";

struct Vote{
    address voter;  // never be ZERO address after instantiated
    address votee;  // target of voting
    uint256 amount;
}

contract VotesL is Context, AccessControl{
    using EnumerableSet for EnumerableSet.AddressSet;

     // votes by project and voter
    mapping(uint256 => mapping(address => Vote)) private votes;    // (project, voter) => (votee, amount)
    
    mapping(uint256 => EnumerableSet.AddressSet) private voters;   // project => voters, keys of votes, for safe access or iteration
    
    ProjectManagerL private projectManager;  // project manager contract
    
    ContributionsL private contribsContract;  // contributions contract
    
    event Voted(uint256 indexed projectId, address indexed voter, address indexed votee, uint256 amt);
    
    event Unvoted(uint256 indexed projectId, address indexed voter);
    
    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Aadmin role is required to do this");
        _;
    }
    
    constructor(address _prjMgr, address _contribsCtr) public{
        require(_prjMgr != address(0), "Contributions: Zero address can't be project manager contract.");
        require(_contribsCtr != address(0), "Contributions: Zero address can't be contributions contract.");
        
        projectManager = ProjectManagerL(_prjMgr);
        contribsContract = ContributionsL(_contribsCtr);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());        
    }
    
    function vote(uint256 _prjId, address _votee, uint256 _amt) public{
        require(_votee != address(0), "Votes: Can't vote on ZERO address.");
        require(_amt > 0, "Votes: Voting ammount should be positive.");

        // validation : project existence, contribution existence, voting right
        require(projectManager.hasProject(_prjId), "Votes: There is no such project.");
        require(contribsContract.hasContribution(_prjId, _votee), "Votes: The specified project has no contributions from the specified votee yet.");

        address vtr = _msgSender(); // voter
        ProjectL prj = ProjectL(projectManager.getProjectAddress(_prjId));
        require(prj.hasVoter(vtr), "Votes: Message sender is not a voter for the specified project.");

        votes[_prjId][vtr] = Vote(vtr, _votee, _amt);
        voters[_prjId].add(vtr);
        emit Voted(_prjId, vtr, _votee, _amt);
    }
    
    function unvote(uint256 _prjId, address) public{
        require(projectManager.hasProject(_prjId), "Votes: There is no such project.");
        
        address vtr = _msgSender(); // voter
        delete votes[_prjId][vtr];
        voters[_prjId].remove(vtr);
        emit Unvoted(_prjId, vtr);
    }
    
    function getVote(uint256 _prjId, address _voter) public view returns (address, uint256) {
        
        Vote memory vt = votes[_prjId][_voter];
        return (vt.votee, vt.amount);
    }
    
    function getVotesByProject(uint256 _prjId) public view returns (Vote[] memory){ //revert free
    
        uint256 l = voters[_prjId].length();
        Vote[] memory vts = new Vote[](l);
        
        for(uint256 i = 0; i < l; i++) vts[i] = votes[_prjId][voters[_prjId].at(i)];
        return vts;
    }
}

    