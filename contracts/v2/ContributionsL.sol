// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "./ProjectManagerL.sol";
import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract ContributionsL is Context, AccessControl{

    struct Contrib{
        address owner;  // should never be ZERO address
        string title;
        string docUrl;
        bytes32 docHash;
    }

    ProjectManagerL private projectManager;
    
    mapping(uint256 => mapping(address => Contrib)) private contribs;  // contributions by project
    
    mapping(uint256 => address[]) private contributors; // contributors by project, index for `contribs`

    event ContributionAdded(uint256 indexed projectId, address indexed contributior);
    
    event ContributionUpdated(uint256 indexed projectId, address indexed contributior);

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Aadmin role is required to do this");
        _;
    }
    
    constructor(address _prjMgr) public{
        require(_prjMgr != address(0), "Contributions: Zero address can't be project manager contract.");
        
        projectManager = ProjectManagerL(_prjMgr);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    
    function addOrUpdateContribution(uint256 _prjId, address _contributior, string memory _title) public onlyAdmin{
        require(projectManager.hasProject(_prjId), "Contributions: There is no such project.");
        require(_contributior != address(0), "Contributions: Contributors address can't be ZERO address.");
        
        bool exists = true;
        if(contribs[_prjId][_contributior].owner == address(0)) exists = false;
        
        contribs[_prjId][_contributior] = Contrib(_contributior, _title, "", 0);
        if(exists) emit ContributionUpdated(_prjId, _contributior);
        else{
            contributors[_prjId].push(_contributior);
            emit ContributionAdded(_prjId, _contributior); 
        }
    }
    
    function getContributorsByProject(uint256 _prjId) public view returns (address[] memory){
        require(projectManager.hasProject(_prjId), "Contributions: There is no such project.");
        
        return contributors[_prjId];        
    }
    
    function getContribution(uint256 _prjId, address _contributor) public view returns (string memory, string memory, bytes32){
        require(projectManager.hasProject(_prjId), "Contributions: There is no such project.");
        
        Contrib memory cntrb = contribs[_prjId][_contributor];
        require(cntrb.owner != address(0), "Contributions: There is no contribution for specified project from specified contributor.");
        
        return (cntrb.title, cntrb.docUrl, cntrb.docHash);
    }
    
    function hasContribution(uint256 _prjId, address _contributor) public view returns (bool){
        if(!projectManager.hasProject(_prjId)) return false;
        
        if(contribs[_prjId][_contributor].owner == address(0)) return false;
        return true;
    }

}