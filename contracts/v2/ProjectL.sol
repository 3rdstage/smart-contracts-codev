pragma solidity ^0.6.0;
//pragma experimental ABIEncoderV2;

import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";


contract ProjectL{
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 internal id;

    string private name;
    
    EnumerableSet.AddressSet private voters;
    
    constructor(uint256 _id, string memory _name) public{
        id = _id;
        name = _name;
    }
  
    function getId() external view returns (uint256){
        return id;
    }
    
    function getName() public view returns (string memory){
        return name;
    } 
  
    
    function setVoters(address[] memory _voters) public{
        uint256 l = voters.length();
        
        for(uint256 i = l; i > 0; i--){
            voters.remove(voters.at(i - 1));
        }
        
        for(uint i = 0; i < _voters.length; i++){
            voters.add(_voters[i]);
        }
    }
    
    // will retrun empty array at initial state
    function getVoters() public view returns (address[] memory){
        uint256 l = voters.length();
        address[] memory _voters = new address[](l);
        
        for(uint256 i = 0; i < l; i++){
            _voters[i] = voters.at(i);
        }
        return _voters;
    }
    
    function hasVoter(address _voter) external view returns (bool){
        return voters.contains(_voter);
    }
  
  



  



}
