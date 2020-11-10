// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "./Commons.sol";
import "./ProjectManager.sol";
import "./Project.sol";
import "./Contributions.sol";


contract VotesL is Context, AccessControl{
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    ProjectManagerL private projectManager;  // project manager contract
    
    ContributionsL private contribsContract;  // contributions contract

     // votes by project and voter
    mapping(uint256 => mapping(address => Vote)) private votes;    // (project, voter) => (votee, amount)
    
    mapping(uint256 => EnumerableSet.AddressSet) private voters;   // project => voter, keys of votes, for safe access or iteration
    
    mapping(uint256 => mapping(address => uint256)) private scores;  // (project, votee) => score
    
    mapping(uint256 => EnumerableSet.AddressSet) private votees;  // project => votee, keys of scores, for safe access or iteration

    event Voted(uint256 indexed projectId, address indexed voter, address indexed votee, uint256 amt, uint256 score);
    
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

        // update `scores` first
        if(votes[_prjId][vtr].voter != address(0)){    // has pervious vote
            uint256 amt0 = votes[_prjId][vtr].amount;  // previous vote amount
            uint256 scr0 = scores[_prjId][_votee];     // votee's current score
            scores[_prjId][_votee] = scr0.sub(amt0).add(_amt);
        }else{                                         // has no previous vote
            uint256 scr0 = scores[_prjId][_votee];     // votee's current score, is 0 when no voter has voted for this votee before
            scores[_prjId][_votee] = scr0.add(_amt);
        }
        votees[_prjId].add(_votee);                    // update `scores`' keys

        // update `votes` and `votes`' keys
        votes[_prjId][vtr] = Vote(vtr, _votee, _amt);
        voters[_prjId].add(vtr);
        
        emit Voted(_prjId, vtr, _votee, _amt, scores[_prjId][_votee]);
    }
    
    
    // @TODO Not complete - remove or finish this.
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
    
    function getVotesByProject(uint256 _prjId) public view returns (Vote[] memory){ 
    
        uint256 l = voters[_prjId].length(); 
        Vote[] memory vts = new Vote[](l);  // what if `l` is ZERO
        
        for(uint256 i = 0; i < l; i++) vts[i] = votes[_prjId][voters[_prjId].at(i)];
        return vts;
    }
    
    function getScoresByProject(uint256 _prjId) public view returns (Score[] memory){
        
        uint256 l = votees[_prjId].length();
        Score[] memory scrs = new Score[](l); // what if `l` is ZERO
        
        for(uint256 i = 0; i < l; i++){
            address vtee = votees[_prjId].at(i);
            scrs[i] = Score(vtee, scores[_prjId][vtee]);
        }
        return scrs;
    }
}

    