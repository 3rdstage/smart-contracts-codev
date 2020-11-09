// SPDX-License-Identifier: GPL-3.0
pragma solidity >0.6.6 <0.7.0;
pragma experimental ABIEncoderV2;
import "../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Address.sol";
import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "./ERC20PresetMinterPauser.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./AbstractRewardPolicy.sol";
import "./IRewardPolicy.sol";


contract Project is Context ,AccessControl {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");
    //libraries
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet; 
    //meta variables
    struct Voter {
        address voterAccount ;
        uint256 voteAmount; 
        bool voted;  
        address voteeAccount;
    }

    struct TargetCompany {
        address companyAddress;
        uint256 votedAmount;

    }

    struct WinningCompany {
        address companyAddress;
        uint totalAmount;
    }

    //storage variables
    Voter[] private votersArr;
    //TargetCompany[] private companyArr;
    //TargetCompany[] private companyArr;

    EnumerableSet.AddressSet private voterAddressSet;
    EnumerableSet.AddressSet private companyAddressSet;

    mapping(address => Voter) voters;
    mapping(address => TargetCompany) targetCompanys;

    address private projectOwner;
    uint256 private projectEndTime;
    //address private rewardPolicy;
    ERC20PresetMinterPauser token;
    bool endProject;
    string private projectName;
    IRewardPolicy rewardPolicy;
    //Events
    event VoterAdded();
    event CompanyAdded();

    constructor(
        address _projectOwner,
        uint256 _endTime,
        ERC20PresetMinterPauser _token,
        address _rewardPolicy) public {
        _setupRole(ADMIN_ROLE, _projectOwner);
        //_setupRole(VOTER_ROLE, address(0));
        token = _token;
        projectEndTime = block.timestamp + _endTime;
        endProject = false;
        rewardPolicy = IRewardPolicy(_rewardPolicy);
        
    }
    
    function setRewardPolicy(address _rewardPolicy) external{
        rewardPolicy = IRewardPolicy(_rewardPolicy);
    }

    function addVoter(address _voterAccount) external {
        require(hasRole(ADMIN_ROLE, _msgSender()), "addVoter() must have admin role to create.");

        Voter memory voter = Voter(_voterAccount,0,false, address(0) );
        voters[_voterAccount] = voter;
        voterAddressSet.add(_voterAccount);

        emit VoterAdded();

    }

    function addCompany(address _companyAccount) external {
        require(hasRole(ADMIN_ROLE, _msgSender()), "addCompany() must have admin role to create.");
        require(companyAddressSet.length() < 2, "addCompany() can add only two companies.");
        
        TargetCompany memory targetCompany = TargetCompany(_companyAccount, 0);
        targetCompanys[_companyAccount] = targetCompany;
        companyAddressSet.add(_companyAccount);

        emit CompanyAdded();
 
    }

    //msg.sender로 구현하는 것이 맞다.(?) id를 관리한다.
    function voting(uint256 _voteAmount, address _voteeAddress) external {
        require(voterAddressSet.contains(_msgSender()), "You are not in voter list.");
        require(endProject == true, "is not ended.");
        require(companyAddressSet.contains(_voteeAddress), "The company is not in the list.");
        require(voters[_msgSender()].voteeAccount == targetCompanys[_voteeAddress].companyAddress, "You voted aleady. If you want to vote another company, first unvoting that.");
 
        TargetCompany storage company = targetCompanys[_voteeAddress];
        Voter storage voter = voters[_msgSender()];

        voter.voteAmount = _voteAmount;
        voter.voted = true;
        voter.voteeAccount = company.companyAddress;

        company.votedAmount += _voteAmount;

    }

    function reveal() external {
        require(hasRole(ADMIN_ROLE, _msgSender()), "reveal() must have admin role to create.");
        require( companyAddressSet.length() != 0, "There is no TargetCompany.");
        require( voterAddressSet.length() != 0, "There is no Voter.");
        require( endProject == false, "This Project is ended.");

        //End conditions
        endProject = true;
        //voterIds
        //voters
        //voterId
        //Uint[2][] public T = new uint[2][](0);
        //[{0x...,100},{0x..., 1000}, {0x..., 2000}]

        _generateWinner();
        //_rewardToVoter();
        // _rewardToCompany();

    }

    function _generateWinner() internal {
        require(endProject == true, "Project is not ended.");
        require(hasRole(ADMIN_ROLE, _msgSender()), "rewardToVoter() must have admin role to create.");

        //mapping converto structure array
        //= new TargetCompany[](companyAddressSet.length());
        //will move to util
        TargetCompany[] memory companyArr = new TargetCompany[](companyAddressSet.length());
        for( uint256 i = 1; i <= companyAddressSet.length(); i++){
            companyArr[i] = targetCompanys[companyAddressSet.at(i)]; 
        }

        //     환경 성과 평가 대상 기업 Voting 결과를 확인한다.
        //      e.g. A기업 : X득표, B기업 : Y득표
        //      => X = 6 ESV,  Y = 4 ESV 
        //      => A기업 득표율 : 60% (득표율 = 100% x X/(X+Y))
        //      => B기업 득표율 : 40% (득표율 = 100% x Y/(X+Y))
        //       10. Reward의 70%를 Voting 결과 대상 업체들에게 Token으로 보상 Smart Contract
        //  -. Voting 대상 기업들에게 Voting 득표율에 따른 Token보상 자동화(배당률 : 전체 Reward Pot의 70%)
        //     => A기업 Reward = Reward용 Token x A기업 득표율 x 배당률 = 100 ESV x 60% x 70% = 42 ESV
        //     => B기업 Reward = Reward용 Token x B기업 득표율 x 배당률 = 100 ESV x 40% x 70% = 28 ESV
        //      11. Reward의 30%는 Voter들에게 분배(Top1 Voter에게 1.5배 지정) Smart Contract
        //  -. reward 로직은 아래와 같다
        //   1) Voter들에게 Reward 보상(배당률 : 전체 Reward Pot의 30%) 기준
        //     - Top1 Voter들에게 1.5배 배정, 나머지 Voter들에게는 1배 배정
        //     - Voting 모수 = Top1기업에게 Voting한 Total ESV x 1.5 + 나머지 기업에 Voting한 Total ESV x 1.0
        //       => Top1기업에게 Voting한 Voter = Voting ESV x Reward 배당률(30%) x 1.5배 / (Voting모수)
        //       => 나머지 기업에 Voting한 Voter = Voting ESV x Reward 배당률(30%) x 1.0배 / (Voting모수)
        //   2) Voter들에게 Reward 보상 예
        //     - Voter1은 A기업에 3 ESV vote => 3 ESV x 30% x 1.5 / ((6 ESV * 1.5) + (4 ESV * 1.0)) = 10.38 ESV → Voter1에게 제공
        //     - Voter2는 A기업에 3 ESV vote => 3 ESV x 30% x 1.5 / ((6 ESV * 1.5) + (4 ESV * 1.0)) = 10.38 ESV → Voter2에게 제공
        //     - Voter3는 B기업에 4 ESV vote => 4 ESV x 30% x 1.0 / ((6 ESV * 1.5) + (4 ESV * 1.0)) =   9.23 ESV → Voter3에게 제공
        // for( uint256 i = 0; i <= companyArr.length(); i++){

        //     if( max <  companyArr[i].totalAmount){
        //         //max = targetCompanys[targetAddressSet.at(i)].totalAmount;
        //         winner = companyArr[i].companyAddress;
        //     }
        // }
        //logic

        //_rewardToVoter(companyArr);
        _rewardToCompany(companyArr);
    }
    // function _rewardToVoter(Voter[] memory _companyArray) internal {
    //     require(endProject == true, "Project is not ended.");
    //     require(hasRole(ADMIN_ROLE, _msgSender()), "rewardToVoter() must have admin role to create.");
        
    //     rewardPolicy.rewardToVoter(_companyArray);
    // }
    
    function _rewardToCompany(TargetCompany[] memory _companyArray) internal {
        require(endProject == true, "Project is not ended.");
        require(hasRole(ADMIN_ROLE, _msgSender()), "rewardToVoter() must have admin role to create.");
  
        rewardPolicy.rewardToCompany(_companyArray);
    }
}