const IRewardModel = artifacts.require("IRewardModelL");
const Only2VoteesAllowedModel = artifacts.require("Only2VoteesAllowedModelL");
const Top2RewardedModel = artifacts.require("Top2RewardedModelL");
const WinnerTakesAllModel = artifacts.require("WinnerTakesAllModelL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("Only2VoteesAllowedModel contract uint tests", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 8) accounts = accounts.slice(0, 8);

  const EventNames = {
  };

  const votees = []; // fill in the `before` function
  const voters = []; // fill in the `before` function

  async function createFixtures(){
 
    const chance = new Chance();
    const admin = chance.pickone(accounts);
    const rewardModel = await Only2VoteesAllowedModel.new({from: admin});

    return [chance, admin, rewardModel];
  }
  
  before(async() => {
    assert.isAtLeast(accounts.length, 8, "There should at least 8 accounts to run this test.");

    votees.push(accounts[2]);
    votees.push(accounts[3]);
    votees.push(accounts[4]);
    voters.push(accounts[5]);
    voters.push(accounts[6]);
    voters.push(accounts[7]);

    const accts = [];
    let balance = 0;

    for(const acct of accounts){
        await web3.eth.personal.unlockAccount(acct);
        await accts.push([acct, await web3.eth.getBalance(acct)]);
    }

    console.debug(`The number of accounts : ${accounts.length}`);
    console.table(accts);
  });
  
  it("...", async() => {
    const [chance, admin, rewardModel] = await createFixtures();
    
    const vts = [];
    vts.push({voter: voters[0], votee: votees[0], amount: toBN(3E18)});
    vts.push({voter: voters[1], votee: votees[1], amount: toBN(4E18)});
    
    await rewardModel.calcContributorRewards(toBN(3E20), vts);  
    
    
  });

});