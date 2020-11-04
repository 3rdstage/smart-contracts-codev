### Development Principles

#### Design Principles

* ***Extended Domain Model***
    * Inclusive and extended
    * `RewardPolicy`
    * `ProjectFactory`
    
* ***Modulization***
    * Divide and Conquerß
    * High Cohesion and Low Coupling
    
* ***On-chain First***
    * Minimize off-chain usage
    
* ***More Fluent API using ABIEncoderV2***
    * Dyanmic array or struct in function parameters and outputs

* ***Follow EIP Standars***
    
* ***Secure Contract***
    * Code inspection using `MythX`(ConsenSys), `Slither`, and `Solhint`
    * Thorough uint testing

* ***Formal Contract API Documentation***

----

#### Implementation Principles

* ***Resue Best Practices***
    * [`OpenZeppelin Contract`](https://github.com/OpenZeppelin/openzeppelin-contracts) library
        * v3.2.0 for Solidity 0.6.x compatibility

        | Library | Description |
        | ------- | ----------- |
        | [`Context`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/GSN/Context.sol) |            |
        | [`AccessControl`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/access/AccessControl.sol) |   |
        | [`SafeMath`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol) | overflow free arithmetics |
        | [`EnumerableSet.AddressSet`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol) |   |
        | [`EnumerableMap.UintToAddressMap`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableMap.sol) |   |
        

----

#### Test Principles

* ***Testing in Testnets via Infura***
        
----

### References

| Reference | Remarks |
| --------- | ----------- |
| [Solidity 0.6.x Documentation](https://solidity.readthedocs.io/en/v0.6.12/) |   |
| [OpenZeppelin Contracts 3.x API](https://docs.openzeppelin.com/contracts/3.x/) |   |
| [Truffle / Conract Abstraction](https://www.trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts) |   |
| [Truffle / Writing Tests in JavaScript](https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript) |   |
| [ChanceJS API](https://chancejs.com/index.html) |   |
| [JavaScript Standard Built-in Objects](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects) | `Array`, `JSON`, `Map`, `Promise`, `RegExp`, `String`, ... |

----

### Sketch

#### Pseudo Codes for Contracts

```javascript

contract ProjectFactory{

  uint256 lastPrjId = 0;

  mapping(uint => address) projects
  
  function createProject() public{
    lastPrjId++;
    Project prj = new Project(lastPrjId);
     
    projects[lastPrjId] = prj;
  }
    
  function getProjectAddress(uint _prjId) public view returns (address){
     return projects[prjId];
   }
}


contract Project{

   uint id;
   string name;
   
   EnumerableAddressSet voters;
   uint256 voteExpireAt;
   
   constructor(uint _id, string memory _name){
     id = _id;
     name = _name;
   }
   
   function getVoters() public view returns (address[]){
     ...
   }
   
   function setVotes(address[] _voters) public{
     ...
   }
   
   function getVoteExpire() public view returns (uint256){
     ...
   }
}   
  
  
contract Vote{
  
  ProjectFactory pf;
   
  constructor(address _pf) public{
     pf = _pf;
  }
  
  function vote(uint _prjId, address _contributorAddr){
    prjAddr = pf.getProjectAddress(prjId);
    prjAddr.getVoteExpire()
    
    // check vote expire date has passed or not    
    ...
  }
}

```     
  
#### Simple Data-model with Sample Data

````

--------------------
Project
--------------------
  projectId, voters
--------------------
  p1, [v1, v2, v3]
  p2, [v3, v4]
--------------------
  

--------------------
<<EOA>> Partner
--------------------
  address, id 
--------------------
         ,  A
         ,  B
         ,  C
         ,  D
--------------------


--------------------
<<EOA>> Voter
--------------------
  id
--------------------
  v1
  v2
  v3
  v4
  v4    
--------------------

         
--------------------
Conribution
--------------------
  contributionId, projectId, partnerId
--------------------
  c1, p1, A
  c2, p1, B
  c3, p2, A
  c4, p2, C
  c5, p2, D
--------------------

  
--------------------
Voting
--------------------
  projectId, voterId, contributionId 
  p1, v1, c1
  p1, v2, c1
  p1, v3, c2
  p2, v3, c3
  p2, v4, c5
--------------------

````  







