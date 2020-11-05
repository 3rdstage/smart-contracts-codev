pragma solidity ^0.6.0;
//pragma experimental ABIEncoderV2;

import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "./ProjectL.sol";

contract ProjectManagerL is Context, AccessControl{
    using Counters for Counters.Counter;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    
    Counters.Counter private idCounter;
    
    EnumerableMap.UintToAddressMap private projects;  // Map(key id, value address)

    event ProjectCreated(uint256 indexed id, address addr);

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Aadmin role is required to do this");
        _;
    }
    
    constructor() public{
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function createProject(string memory _name) public onlyAdmin{
        idCounter.increment();
        uint256 id = idCounter.current();
        // new project may not be included in the `projects` already
        assert(!projects.contains(id));
        
        ProjectL prj = new ProjectL(id, _name);
        address addr = address(prj);
        projects.set(id, addr);
        
        emit ProjectCreated(id, addr);
    }
    
    function getNumberOfProjects() public view returns (uint256){
        return projects.length();
    }
    
    function hasProject(uint256 _prjId) public view returns (bool){
        return projects.contains(_prjId);
    }
    
    function getProjectAddress(uint256 _prjId) public view returns (address){
        require(projects.contains(_prjId), "ProjectManager: There's no project with the specified project ID.");
        
        return projects.get(_prjId);
    }
    
    
    
}