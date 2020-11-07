// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./VotesL.sol";

interface IRewardModelL{

    function calcContributorRewards(uint256 totalAmount, VotesL.Vote[] calldata votes) external view;
    
    function calcVoterRewards(uint256 totalAmount, VotesL.Vote[] calldata votes) external view;

}