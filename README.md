## 프로젝트 산출물 구성

2020년 4회 경연대회 주제 2 "SK Hynix JDP 환경성과 기여에 따른 Reward 제공" 구현 프로젝트로 다음과 같은 산출을을 포함합니다.

| Directory | File | 설명 | 비고 |
| --------- | ---- | --- | --- |
| `/`             |     |     |     |
|                 | `truffle-config`   | Truffle 환경설정 파일 |   |   |
|                 | `package.json`     | `npm`의 package 정의 파일 |   |   |
| `contracts/v2/` |     |     |     |
|                 | `Commons.sol`      | 모든 smart contract 들에서 공통으로 사용하는 구조체(`struct`)들을 정의 |   |
|                 | `Contribution.sol` | 프로젝트에 참여한 각 기업의 참여/***기여*** 데이터를 저장하고 관련 기능을 수행하는 smart contract |   |
|                 | `IRewardModel.sol` | 투표에 따른 ***보상***(reward)를 계산하는 다양한 pluggable smart contract들을 위한 ***interface*** 정의 |   |
|                 | `Project.sol`      | 개별 ***프로젝트*** 데이터를 저장하는 smart contract |   |
|                 | `ProjectManager.sol` | 프로젝트 생성 및 전체적으로 workflow 수준의 기능을 수행하는 mamager smart contract |   |
|                 | `Votes.sol`        | 전체 ***투표*** 데이터를 저장하고 투표 관련 기능을 수행하는 smart contract |   |
| `contracts/v2/rewardmodels` |     |     |
|                 | `EvenVoterRewardModel.sol` | 기여자들에게는 득표에 비례하는 보상을 지급하고, 투표자들에게는 균등하게 보상을 지급하는 모델 |   |
|                 | `EvenVoterRewardModel.sol` |   |   |   |
| `test/v2/`      |     |     |     |
|                 | `TestContribution.js`        | `Contribution` contrac 단위 테스트 |   |
|                 | `TestIntegratedScenarios.js` | 경연대회 시나리오를 포함하여 몇몇 시나리오들을 검증하는 통합 테스트 |   |
|                 | `TestProject.js'             | `Project` contract 단위 테스트 |   |
|                 | `TestProjectManager.js`      | `ProjectManager` contract 단위 테스트 |   |

----

## 시작하기 (Getting Started)




### 시나리오

* 모든 시나리오에서 총상금 : **100 ESV**, 기여자 총상금 비율: **70 %**

* ***Scenario 1***
    * 경연 공식 시나리오
        
        | Votee     | Score | Reward |
        | --------- | ----- | ------ |
        | `votee.0` |     6 |     42 |    
        | `votee.1` |     4 |     28 |
        | sum       |    10 |     70 |
        
        | Voter     | Votes For | Amount | Portion | Reward |
        | --------- | --------- | ------ | ------- | ------ |
        | `voter.0` | `votee.0` |      3 |     1.5 |  10.38 |
        | `voter.1` | `votee.0` |      3 |     1.5 |  10.38 |
        | `voter.2` | `votee.1` |      4 |     1.0 |   9.23 |
        | sum       |           |     10 |         |  29.99 |


* ***Scenario 2***
    * 2명의 투표 대상자가 동점인 경우 
        | Votee     | Score | Reward |
        | --------- | ----- | ------ |
        | `votee.0` |     6 |     35 |    
        | `votee.1` |     6 |     35 |
        | sum       |    12 |     70 |
        
        | Voter     | Votes For | Amount | Portion | Reward |
        | --------- | --------- | ------ | ------- | ------ |
        | `voter.0` | `votee.0` |      3 |     1.5 |    7.5 |
        | `voter.1` | `votee.0` |      3 |     1.5 |    7.5 |
        | `voter.2` | `votee.1` |      6 |     1.5 |   15.0 |
        | sum       |           |     12 |         |   30.0 |        


----

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






