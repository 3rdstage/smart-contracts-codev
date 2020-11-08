const ProjectManager = artifacts.require("ProjectManagerL");
const IRewardModel = artifacts.require("IRewardModelL");
const Only2VoteesAllowedModel = artifacts.require("Only2VoteesAllowedModelL");
const Top2RewardedModel = artifacts.require("Top2RewardedModelL");
const WinnerTakesAllModel = artifacts.require("WinnerTakesAllModelL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("ProjectManager Uint Tests", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 8) accounts = accounts.slice(0, 8);
  
  
  const rewardModels = [];
  const EventNames = {
  };

  async function createFixtures(){
    const chance = new Chance();
    const admin = chance.pickone(accounts);
    const prjMgr = await ProjectManager.new({from: admin});

    return [chance, admin, prjMgr];
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
  
  
  it("Should have no project or reward model initially.", async() => {
    const [chance, admin, prjMgr] = await createFixtures();
    
    const cnt1 = await prjMgr.getNumberOfProjects();
    const cnt2 = await prjMgr.getNumberOfRewardModels();
    
    assert.isTrue(cnt1.isZero(), "Initially there should be no project in a project manager contract.");
    assert.isTrue(cnt2.isZero(), "Initially there should be no reward model in a project manager contract.");
  });
  
  
  it("Can count the number of created projects", async() => {
    const [chance, admin, prjMgr] = await createFixtures();
    
    const n = chance.natural({min: 3, max: 10});
    for(let i = 0; i < n; i++){
      await prjMgr.createProject(chance.word({length: chance.natural({min: 5, max: 15})}), {from: admin});
    }
  
    const cnt = await prjMgr.getNumberOfProjects();
    
    assert.isTrue(cnt.eqn(n), "Number of created projects are different from the number that project manager contract counts");   
    
  });
  
  it.only("Can register reward models", async() => {
    const [chance, admin, prjMgr] = await createFixtures();
    const addrs = [], names = [];
    
    for(const model of rewardModels){
      addrs.push(model.address);
      await prjMgr.registerRewardModel(model.address, {from: admin});
      names.push(await model.getName());
    }
    console.log("Registering model names: " + names.toString());
    
    const cnt = await prjMgr.getNumberOfRewardModels();
    assert.isTrue(cnt.eqn(rewardModels.length));    
    
    let mdl2 = null;
    const addrs2 = [], names2 = [];
    for(let i = 0; i < cnt; i++){
      mdl2 = await prjMgr.getRewardModel(i)
      console.log(mdl2);
      addrs2.push(mdl2.addr);
      names2.push(mdl2.name);
    }
  
    console.log("Registered model names: " + names2.toString());
    assert.sameMembers(names, names2, "Wrong reward model is registered.");
    assert.sameMembers(addrs, addrs2, "Wrong reward model is registered."); 
    
  });
  
});
  