pragma solidity >0.6.6 <0.7.0;
pragma experimental ABIEncoderV2;
import "./Project.sol";
interface IRewardPolicy {

    event RewardToVoter();
    event RewardToCompany();
    function rewardToVoter() external;
    //function rewardToCompany(TargetCompany[] calldata _companyAccount) external;
    function rewardToCompany(Project.TargetCompany[] calldata _companyAccount) external;
}