pragma solidity >0.6.6 <0.7.0;
pragma experimental ABIEncoderV2;

interface IRewardPolicy {
    
    struct TargetCompany {
        address companyAddress;
        uint256 votedAmount;

    }

    struct RewardResultToCompany {
        address companyAddress;
        uint256 reward;
    }

    event RewardToVoter();
    event RewardToCompany();
    function rewardToVoter() external;
    function rewardToCompany(TargetCompany[] calldata _companyAccount) external;
}