// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Votes.sol";

struct Reward{
    address to;
    uint256 amount;
}

interface IRewardModelL{

    function getName() external view returns (string memory);

    function calcContributorRewards(uint256 totalAmount, Vote[] calldata _votes) external view returns (Reward[] memory voterRewards, Reward[] memory voteeRewards);
    
    function calcVoterRewards(uint256 totalAmount, Vote[] calldata _votes) external view returns (Reward[] memory voterRewards, Reward[] memory voteeRewards);

}