// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Votes.sol";

interface IRewardModelL{
    
    function getName() external view returns (string memory);

    function calcContributorRewards(uint256 totalAmount, VotesL.Vote[] calldata votes) external view;
    
    function calcVoterRewards(uint256 totalAmount, VotesL.Vote[] calldata votes) external view;

}