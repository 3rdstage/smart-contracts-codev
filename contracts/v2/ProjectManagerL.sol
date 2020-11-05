pragma solidity ^0.6.0;
//pragma experimental ABIEncoderV2;

import "../../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "./ProjectL.sol";

contract ProjectManagerL{
    using Counters for Counters.Counter;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    
    Counters.Counter private idCounter;
    EnumerableMap.UintToAddressMap private projects;  // Map(key id, value address)
    
    function createProject(string memory _name) public{
        idCounter.increment();
        uint256 id = idCounter.current();
        // new project may not be included in the `projects` already
        assert(!projects.contains(id));
        
        ProjectL prj = new ProjectL(id, _name);
        projects.set(id, address(prj));
    }
    
    function getNumberOfProjects() public view returns(uint256){
        return projects.length();
    }
    
}