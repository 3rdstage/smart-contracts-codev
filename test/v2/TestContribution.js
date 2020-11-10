const ProjectManagerContr = artifacts.require("ProjectManagerL");
const ContributionsContr = artifacts.require("ContributionsL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("Contribution contract uint tests", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);

  const votees = []; // fill in the `before` function
  const voters = []; // fill in the `before` function

  async function createFixtures(){
 
    const chance = new Chance();
    const admin = chance.pickone(accounts);
    const prjMgrContr = await ProjectManagerContr.new({from: admin});
    const contribsContr = await ContributionsContr.new(prjMgrContr.address, {from: admin});

    return [chance, admin, prjMgrContr, contribsContr];
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
    const [chance, admin, prjMgrContr, contribsContr] = await createFixtures();
    
    const prj = {name: 'p1', totalReward: toBN(1E20), totalRewardStr: '1E20',
                  contribPrct: 70, rewardModelAddr: constants.ZERO_ADDRESS};
                  
    const rcpt = await prjMgrContr.createProject(
      prj.name, prj.totalReward, prj.contribPrct, prj.rewardModelAddr, {from: admin});
    console.log(rcpt);
    expectEvent(rcpt, 'ProjectCreated');
    ev = rcpt.lgs[0].args;
    
    
    
  });

});