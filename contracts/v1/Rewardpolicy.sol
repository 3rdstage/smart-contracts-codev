// SPDX-License-Identifier: GPL-3.0
pragma solidity >0.6.6 <0.7.0;
pragma experimental ABIEncoderV2;
import "../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Address.sol";
import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "./ERC20PresetMinterPauser.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";
import "./AbstractRewardPolicy.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./Project.sol";

contract RewardPolicy is AbstractRewardPolicy {

    //libraries
    using SafeMath for uint256;
    using Address for address;
    using EnumerableMap for EnumerableMap.UintToAddressMap; 

    //will move to super.contruct?
    //reward amount
    uint256 private constant rewardTotalAmount = 100; 
    uint256 private constant rewardToCompanyRatio = 70;
    uint256 private constant rewardToVoterRatio = 30;
    uint256 private constant roundUpPoint = 10; // 10 mean .x, 100 means .xx 
    //reward ratio
    uint256 private constant rewardRatioToTop = 3;
    uint256 private constant rewardRatioToOthers = 2;
    uint256 public testi;
    uint256 public testj;
    address public testad;
    
    struct RewardResultToCompany {
        address companyAddress;
        uint256 reward;
    }

    struct RewardResultToVoter {
        address companyAddress;
        uint256 reward;
    }
    
    constructor(
        address _projectOwner,
        uint256 _endTime,
        ERC20PresetMinterPauser _token) public {
        
        
    }

    function rewardToVoter() override public {


    }

    function rewardToCompany(Project.TargetCompany[] memory _companysArray) override public {
            uint256 totalAmount = 0;
            uint256[] memory myAmount = new uint256[](_companysArray.length);
            RewardResultToCompany[] memory rrtcCom = new RewardResultToCompany[](_companysArray.length);
            //rrtcCom = RewardResultToCompany
            //testi = myAmount.length;
            //testj = _companysArray.length;
            //705 vs 294 , 707, 292
            //if +5 고 10으로 나눳을때 몫이 증가했으면 그쪽을 반올릴예정
            //calc totalAmount
            for(uint256 i = 0; i < _companysArray.length; i++){
                totalAmount += _companysArray[i].votedAmount;
            }
            testi= totalAmount;
            //require(totalAmount !=0, "vo")
            //cal my reward
            for(uint256 j = 0; j < _companysArray.length; j++){
                //1. cal ratio
                //e.g. 12 , 5 , 6 => 1200 /21 70.5xxx , 500 / 21 = 29.4xxx, 300 / 21 = 
                //testj = _companysArray[j].votedAmount * 100 /  totalAmount;
                uint256 myratio = _companysArray[j].votedAmount * 100 /  totalAmount;
                //2. cal my pie
                // myrate = 70%, 70%
                //testj = rewardTotalAmount * myratio * rewardToCompanyRatio / 10000;
                uint256 myReward = rewardTotalAmount * myratio * rewardToCompanyRatio / 10000;
                //testad = _companysArray[j].companyAddress;
                rrtcCom[j] = RewardResultToCompany(_companysArray[j].companyAddress, myReward );
            }
            //using for
            //token.mint();
    }
}