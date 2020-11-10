// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Commons.sol";

interface IRewardModelL{

    function getName() external view returns (string memory);

    // @TODO Can return `calldata` struct array ?
    function calcContributorRewards(RewardPot calldata _rewardPot, Vote[] calldata _votes, Score[] calldata _scores) external view returns (Reward[] memory voterRewards, Reward[] memory voteeRewards);
    
    function calcVoterRewards(uint256 _totalAmt, Vote[] calldata _votes) external view returns (Reward[] memory voterRewards, Reward[] memory voteeRewards);

}