const ProjectManager = artifacts.require("ProjectManagerL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("ProjectManagerL Uint Tests", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 8) accounts = accounts.slice(0, 8);

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

    console.debug(`The number of accounts : ${accounts.length}`);
    console.table(table);
  });
  
  
  it("Should have no project initially.", async() => {
    const [chance, admin, prjMgr] = await createFixtures();
    
    const cnt = await prjMgr.getNumberOfProjects();
    
    assert.equal(cnt, 0, "Initially there should be no project in a project manager contract.");
  });
  
  
  it("Can count the number of created projects", async() => {
    const [chance, admin, prjMgr] = await createFixtures();
    
    const n = chance.natural({min: 3, max: 10});
    for(let i = 0; i < n; i++){
      await prjMgr.createProject(chance.word({length: chance.natural({min: 5, max: 15})}));
    }
  
    const cnt = await prjMgr.getNumberOfProjects();
    
    assert.equal(cnt, n, "Number of created projects are different from the number that project manager contract counts");   
    
  })
  
});
  