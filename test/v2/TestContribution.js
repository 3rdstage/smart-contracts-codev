const ProjectManagerContr = artifacts.require("ProjectManagerL");
const ProportionalRewardModelContract = artifacts.require("ProportionalRewardModelL");
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

  async function createFixtures(deployed = false){
    
    const chance = new Chance();
    const admin = chance.pickone(accounts);
    let prjMgrContr, contribsContr;
    
    if(deployed){
      prjMgrContr = await ProjectManagerContr.deployed();
      contribsContr = await ContributionsContr.deployed();
    }else{
      prjMgrContr = await ProjectManagerContr.new({from: admin});
      const rwdModelContr = await ProportionalRewardModelContract.new(15, 10, {from: admin})
      await prjMgrContr.registerRewardModel(rwdModelContr.address, {from: admin});
      contribsContr = await ContributionsContr.new(prjMgrContr.address, {from: admin});
    }
  
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
  
  it("Can create project.", async() => {
    const [chance, admin, prjMgrContr, contribsContr] = await createFixtures();
    
    const rwdMdl = await prjMgrContr.getRewardModel(0);    
    
    console.log(rwdMdl);          
    
    const prj = {name: 'p1', totalReward: toBN(1E20), totalRewardStr: '1E20',
                  contribPrct: 70, rewardModelAddr: rwdMdl.addr};
    
    const rcpt = await prjMgrContr.createProject(
      Date.now().toString().substring(0, 12), prj.name, 
      prj.totalReward, prj.contribPrct, prj.rewardModelAddr, {from: admin});
    console.log(rcpt);
    expectEvent(rcpt, 'ProjectCreated');
    const ev = rcpt.logs[0].args;
  });

});