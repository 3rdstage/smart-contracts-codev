const Project = artifacts.require("ProjectL");
const IRewardModel = artifacts.require("IRewardModelL");
const Only2VoteesAllowedModel = artifacts.require("Only2VoteesAllowedModelL");
const Top2RewardedModel = artifacts.require("Top2RewardedModelL");
const WinnerTakesAllModel = artifacts.require("WinnerTakesAllModelL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("Project Uint Tests", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 8) accounts = accounts.slice(0, 8);

  const EventNames = {
  };

  const rewardModels = [];

  async function createFixtures(){
    const chance = new Chance();
    const admin = chance.pickone(accounts);
    const id = 1, name = 'Test Project';
    const totalRwd = toBN(1E20).muln(chance.natural({min: 1, max: 5}));
    const cntrbPrct = chance.natural({min: 50, max: 80});
    const project = await Project.new(id, name, totalRwd, cntrbPrct, constants.ZERO_ADDRESS, {from: admin});

    return [chance, admin, project];
  }
  
  before(async() => {
    const table = [];
    let balance = 0;

    for(const acct of accounts){
        await web3.eth.personal.unlockAccount(acct);
        await table.push([acct, await web3.eth.getBalance(acct)]);
    }

    rewardModels.push(await Only2VoteesAllowedModel.new({from: accounts[0]}));
    rewardModels.push(await Top2RewardedModel.new({from: accounts[0]}));
    rewardModels.push(await WinnerTakesAllModel.new({from: accounts[0]}));

    console.debug(`The number of accounts : ${accounts.length}`);
    console.table(table);
  });
  
  
  // constructor, getId(), getName()
  it("Should set up `id`, `name`, `total reward` and so on correctly at the constructor.", async() => {
    const chance = new Chance();
    const admin = chance.pickone(accounts);
    
    const loops = 5;
    let id = 0, name = null, totalRwd = 0, cntrbPrct = 0, rwdMdlAddr = 0;
    let prj = null, scale = null;
    for(let i = 0; i < loops; i++){
      id++; 
      name = chance.word({length: 10});
      totalRwd = toBN(1E20).muln(chance.natural({min: 1, max: 5})); // total reward
      cntrbPrct = chance.natural({min: 1, max: 99});  // contributors reward pecent           
      rwdMdlAddr = chance.pickone(rewardModels).address; // reward model address
      
      prj = await Project.new(id, name, totalRwd, cntrbPrct, rwdMdlAddr, {from: admin});
    
      assert.equal(await prj.getId(), id, "Project's `id` is not set or queried correclty.");
      assert.equal(await prj.getName(), name, "Project's `name` is not set or queried correctly.");
      
      scale = await prj.getRewardScale();
      assert.isTrue(scale[0].eq(totalRwd), "Project's total reward is not set or queried corectly.");
      assert.isTrue(scale[1].eqn(cntrbPrct), "Project's contributors reward percentage is not set or queried correctly.");
      assert.equal(await prj.getRewardModelAddress(), rwdMdlAddr);
    }
  });
  
  
  it("Should have no voters and be not rewarded initially", async() => {
    
    const [chance, amdin, project] = await createFixtures();
    
    const voters = await project.getVoters();
    assert.isEmpty(voters, "Project should have NO voters assigned initially.");
    assert.isFalse(await project.isRewarded(), "Project should NOT be rewarded initially.");
  });
  
  // setVoters(), getVoters()
  it("Can specify voters", async() =>{
    const [chance, admin, project] = await createFixtures();
    
    const voters = chance.pickset(accounts, 3);
    
    await project.assignVoters(voters, {from: admin});
    const voters2 = await project.getVoters(); 
   
    assert.isTrue(await voters2.map(v => voters.includes(v)).reduce((acc, cur) => acc && cur));
      
  });
  
});
