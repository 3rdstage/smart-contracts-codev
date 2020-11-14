## Features 

| Cateogry | Feature | Description |
| -------- | ------- | ----------- |
| Design   | ***Extended domain model*** | Inclusive, extended and production-ready use-cases and model |
|          | ***Modulization***          | ***Not*** one big hard to read and extend smart contract |
|          | ***On-chain First***        | Keeps and access all important data inside/from ***On-chain*** |
|          | ***Fluent API using `ABIEncoderV2`*** | Dyanmic array or struct in function parameters and returns |
| Implementation | ***Safe operations*** |   |
|                | ***Resue best practices*** | Reuse OpenZeppelin contracts as possible |


* ***Extended Domain Model***
    * Inclusive, extended and production-ready use-cases and model
    * Use-cases
        * `Register Project` use-case
        * `Vote` use-case
        * `Unvote` use-case
        * `Simulate Rewards` use-case
        * `Distribute Rewards` use-case
        
* ***Modulization***
    > High Cohesion and Low Coupling<br>
    > [Separation of Concerns](https://en.wikipedia.org/wiki/Separation_of_concerns)<br>
    > [Single-responsibility Principle](https://en.wikipedia.org/wiki/Single-responsibility_principle)<br>
    > Divide and Conquer
    * Examples in this project 
        * ***Pluggabel reward model(policy)***
            * `IRewardMdel` - `ProportionalRewardModel`, `EvenVoterRewardModel`, `WinnerTakesAllModel`, ...
        * Factory and facade(partially) pattern 
            * `ProjectManager` contract
    * Later extension candidates
        * `Evaluation`, `Patent`
        * Flow control - Before Vote, Vote Open, Vote Closed, Vote Canceled, Rewarded ...
        * Min. and max. for voting amount
    
* ***On-chain First***
    * ***Keeps all important data inside On-chain.***
       | Smart Contract | Ledger(State) | Code |
       | -------------- | ------------- | ---- |
       | `ProjectManager`  | Projects       | `EnumerableMap.UintToAddressMap private projects` |
       |                   | Reward Models  | `mapping(address => string) private rewardModels` |
       | `Contributions`   | Contributions  | `mapping(uint256 => mapping(address => Contrib)) private contribs` |
       | `Votes`           | Votes          | `mapping(uint256 => mapping(address => Vote)) private votes` |
       |                   | Scores         | `mapping(uint256 => mapping(address => uint256)) private scores` |
    * ***Iterates on-chain data using smart contracts***
        | Smart Contract  | Ledger Data Access |
        | --------------- | ------------------ |
        | `Project`       | `assignVoters(address[] calldata _voters) external onlyOwner` |
        |                 | `getVoters() external view returns (address[] memory)` |
        | `Contributions` | `addOrUpdateContribution(uint256 _prjId, address _contributior, string memory _title) public onlyAdmin` |
        |                 | `getContributorsByProject(uint256 _prjId) public view returns (address[] memory)` |
        | `Votes`         | `vote(uint256 _prjId, address _votee, uint256 _amt) public` |
        |                 | `getVotesByProject(uint256 _prjId) public view returns (Vote[] memory)` |
        |                 | `getScoresByProject(uint256 _prjId) public view returns (Score[] memory)` |
    * ***Minimizes off-chain usage***
    
* ***Fluent API using `ABIEncoderV2`***
    * Dyanmic array or struct in function parameters and returns
    
* ***Safe Operations***
    * Solidity's `mapping` is ***NOT iteratable***.
        * Use OpenZeppelin's `EnumerableMap.UintToAddressMap` or auxiliary data for ***key-set***
            ````
            mapping(uint256 => mapping(address => Contrib)) private contribs;  // contributions by project, main collections
            mapping(uint256 => address[]) private contributors;                // contributors by project, key-set for `contribs`
            
            function getContributorsByProject(uint256 _prjId) public view returns (address[] memory);
            function getContribution(uint256 _prjId, address _contributor) public view returns (string memory, string memory, bytes32);
            
            ````
     * Solidity doesn't built-in `set` container data-type.
         * Use OpenZeppelin's `EnumerableSet`
     * Solidity has no built-in referential integrity mechanism
         *  Gurauntee referential integrity by smart contract - not by off-chain or DApp
                   
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

* ***Secure Contract***
    * Code inspection using `MythX`(ConsenSys), `Slither`, and `Solhint`
    * Thorough uint testing

* ***Formal Contract API Documentation***
       
----

## References

| Reference | Remarks |
| --------- | ----------- |
| [Solidity 0.6.x Documentation](https://solidity.readthedocs.io/en/v0.6.12/) |   |
| [OpenZeppelin Contracts 3.x API](https://docs.openzeppelin.com/contracts/3.x/) |   |
| [Truffle / Conract Abstraction](https://www.trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts) |   |
| [Truffle / Writing Tests in JavaScript](https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript) |   |
| [Remix-IDE Documentation](https://remix.readthedocs.io/en/stable/) |   |
| [ChanceJS API](https://chancejs.com/index.html) |   |
| [JavaScript Standard Built-in Objects](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects) | `Array`, `JSON`, `Map`, `Promise`, `RegExp`, `String`, ... |

----






