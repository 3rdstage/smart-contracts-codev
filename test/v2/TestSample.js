const IRewardModel = artifacts.require("IRewardModelL");
const SampleContract = artifacts.require("SampleL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("Sample contract uint tests", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);

  const votees = []; // fill in the `before` function
  const voters = []; // fill in the `before` function

  async function createFixtures(){
 
    const chance = new Chance();
    const admin = chance.pickone(accounts);
    const sampleContr = await SampleContract.new({from: admin});

    return [chance, admin, sampleContr];
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
  
  it("Can return struct array", async() => {
    const [chance, admin, sampleContr] = await createFixtures();
    
    const ver = chance.pickone(voters);
    const vee = chance.pickone(votees);
    const amt = toBN(3E18);
    const vts = await sampleContr.testStructArrayReturn(ver, vee, amt);
    
    for(const [i, vt] of vts.entries()){
      assert.equal(vt.voter, ver);
      assert.equal(vt.votee, vee);
      assert.equal(vt.amount, 3E18);
      //assert.isTrue(vt.amount.eq(amt));
      console.log(`Returned struct ${i}: ` + vt);
    }
    console.log(vts);
    
  });
  
  it("Can accept strut array parameter", async() => {
    const [chance, admin, sampleContr] = await createFixtures();

    const amt = 30000000000;
    const vts = [];
    
    vts.push({voter: voters[0], votee: votees[0], amount: amt});
    vts.push({voter: voters[1], votee: votees[1], amount: amt});    

    const rcpt = await sampleContr.testStructArrayParam(vts, {from: admin});
    console.log(rcpt);
    expectEvent(rcpt, 'VoteIdentified', {0: voters[0], 1: votees[0]});
    expectEvent(rcpt, 'VoteIdentified', {0: voters[1], 1: votees[1]});
  });
  
  it("Can deliver struct array param to another contract.", async() => {
    const [chance, admin, sampleContr] = await createFixtures();

    const ttl = toBN(2E18);
    const amt = 30000000000;
    const vts = [];
    
    vts.push({voter: voters[0], votee: votees[0], amount: amt});
    vts.push({voter: voters[1], votee: votees[1], amount: amt});    

    await sampleContr.testDeliverStructArrayParam(ttl, vts, {from: admin});    
    
    
  });

});