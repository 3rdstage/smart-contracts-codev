// SPDX-License-Identifier: GPL-3.0
pragma solidity >0.6.6 <0.7.0;
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/utils/Address.sol";
import "../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "./ERC20PresetMinterPauser.sol";
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";
import "../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";


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
        uint totalAmount;
    }

    struct WinningCompany {
        address companyAddress;
        uint totalAmount;
    }

    //storage variables
    Voter[] private votersArr;
    //TargetCompany[] private companyArr;

    EnumerableSet.AddressSet private voterAddressSet;
    EnumerableSet.AddressSet private companyAddressSet;

    mapping(address => Voter) voters;
    mapping(address => TargetCompany) targetCompanys;

    address private projectOwner;
    uint256 private projectEndTime;
    address private rewardPolicy;
    ERC20PresetMinterPauser token;
    bool endProject;
    string private projectName;
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
        rewardPolicy = _rewardPolicy;
        
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

        company.totalAmount += _voteAmount;

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
        // _rewardToVoter();
        // _rewardToCompany();

    }

    function _generateWinner() internal {
        require(endProject == true, "Project is not ended.");
        require(hasRole(ADMIN_ROLE, _msgSender()), "rewardToVoter() must have admin role to create.");

        //mapping converto structure array
        TargetCompany[] memory companyArr = new TargetCompany[](companyAddressSet.length());
        
        for( uint256 i = 1; i <= companyAddressSet.length(); i++){
            companyArr[i] = targetCompanys[companyAddressSet.at(i)]; 
        }
        // will move to rewardPolicy
        uint256 max = 0;
        address winner = address(0);
        for( uint256 i = 0; i <= companyArr.length; i++){

            if( max <  companyArr[i].totalAmount){
                //max = targetCompanys[targetAddressSet.at(i)].totalAmount;
                winner = companyArr[i].companyAddress;
            }
        }
        //rewardPolicy.rewardToVoter();
    }
    // function _rewardToVoter() internal {
    //     require(endProject == true, "Project is not ended.");
    //     require(hasRole(ADMIN_ROLE, _msgSender()), "rewardToVoter() must have admin role to create.");
        
    //     //rewardPolicy.rewardToVoter();
    // }

    // function _rewardToCompany() internal {
    //     require(endProject == true, "Project is not ended.");
    //     require(hasRole(ADMIN_ROLE, _msgSender()), "rewardToCompany() must have admin role to create.");

    //     //rewardPolicy.rewardToCompany();
    // }
}