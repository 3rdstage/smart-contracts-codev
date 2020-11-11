const IRewardModel = artifacts.require("IRewardModelL");
const ProportionalRewardModel = artifacts.require("ProportionalRewardModelL");
const Top2RewardedModel = artifacts.require("Top2RewardedModelL");
const WinnerTakesAllModel = artifacts.require("WinnerTakesAllModelL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("ProportionalRewardModel contract uint tests", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);

  const votees = []; // fill in the `before` function
  const voters = []; // fill in the `before` function

  async function createFixtures(){
 
    const chance = new Chance();
    const admin = chance.pickone(accounts);
    const rwdModel = await ProportionalRewardModel.new({from: admin});

    return [chance, admin, rwdModel];
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

    console.debug(`Votees : ${votees.length}`);
    console.table(votees);
    console.debug(`Voters : ${voters.length}`);
    console.table(voters);
    
  });
  
  it("Can calculate.", async() => {
    
    const [chance, admin, rwdModel] = await createFixtures();
    
    const rwdPot = {total: toBN(1E20).toString(), contribsPercent: 70};

    const vts = [];           // votes
    vts.push({voter: voters[0], votee: votees[0], amount: toBN(3E18).toString()});  // voter1 -> A, 3ESV 
    vts.push({voter: voters[1], votee: votees[0], amount: toBN(3E18).toString()});  // voter2 -> A, 3ESV
    vts.push({voter: voters[2], votee: votees[1], amount: toBN(4E18).toString()});  // voter3 -> B, 4ESV
        
    const scrs = [];          // scores
    scrs.push({owner: votees[0], value: toBN(6E18).toString()});
    scrs.push({owner: votees[1], value: toBN(4E18).toString()});
    
    //const rwds = await rwdModel.calcContributorRewards(rwdPot, vts, scrs);
    const rslt = await debug(rwdModel.calcContributorRewards(rwdPot, vts, scrs));
    console.log(rslt);
    
  });

});