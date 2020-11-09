// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Project.sol";
import "../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Address.sol";
import "./ERC20PresetMinterPauser.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";

contract ProjectFactory is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    using EnumerableMap for EnumerableMap.UintToAddressMap; 
    using SafeMath for uint256;
    using Address for address;
    //Project[] public projectAddresses;
    uint256 projectId = 0;
    EnumerableMap.UintToAddressMap private projectIds;
    mapping(address => Project) projects;
    event ProjectCreated(address project);
    ERC20PresetMinterPauser private token;

    address private projectOwner;

    constructor(address _tokenAddress) public {
        projectOwner = msg.sender;
        token = ERC20PresetMinterPauser(_tokenAddress);
        _setupRole(ADMIN_ROLE, _msgSender());
    }

    function createProject(address _projectOwner, uint256 _endTime, address _rewardPolicy) external returns ( uint256 ){
        require(hasRole(ADMIN_ROLE, _msgSender()), "createProject() must have admin role to create.");
        address project = address(new Project(_projectOwner, _endTime, token, _rewardPolicy));

        //projectAddresses.push(project);
        //projects[projectId] = project;
        projectIds.set(projectId, project);
        projectId++;

        emit ProjectCreated(project);

        return projectId;
    }

    function getProject(uint _projectId) external view returns (address) {
        require(projectIds.contains(_projectId), "There is no project.");
        
        return projectIds.get(_projectId);
    }
}