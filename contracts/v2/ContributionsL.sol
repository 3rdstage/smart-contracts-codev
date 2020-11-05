pragma solidity ^0.6.0;
//pragma experimental ABIEncoderV2;

import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "./ProjectManagerL.sol";

contract ContributionsL is Context, AccessControl{

    struct Contrib{
        address owner;
        string title;
        string docUrl;
        bytes32 docHash;
    }

    ProjectManagerL private projectManager;
    
    mapping(uint256 => mapping(address => Contrib)) private contribs;
    
    constructor(address _prjMgr) public{
        require(_prjMgr != address(0), "Contributions: Zero address can't be project manager contract.");
        
        projectManager = ProjectManagerL(_prjMgr);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    
    function addOrUpdateContribution(uint256 _prjId, address _contributior, string memory _title) public{
        require(projectManager.hasProject(_prjId), "Contributions: There is no such project.");
        require(_contributior != address(0), "Contributions: Contributors address can't be ZERO address.");
        
        contribs[_prjId][_contributior] = Contrib(_contributior, _title, "", 0);

    }
    
    
    
    
    
    
    
}