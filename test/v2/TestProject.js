const Project = artifacts.require("ProjectL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("ProjectL Uint Tests", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 8) accounts = accounts.slice(0, 8);

  const EventNames = {
  };

  async function createFixtures(){
    const chance = new Chance();
    const admin = chance.pickone(accounts);
    const project = await Project.new(1, 'Test Project', {from: admin});

    return [chance, admin, project];
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
  
  
  // constructor, getId(), getName()
  it("Should set up `id` and `name` at the constructor", async() => {
    const chance = new Chance();
    const admin = chance.pickone(accounts);
    const id = chance.natural({min: 1, max: 1E5});
    const name = chance.word({length: 10});
    const project = await Project.new(id, name, {from: admin});
    
    assert.equal(await project.getId(), id, "Contract's `id` is not set or queried correclty.");
    assert.equal(await project.getName(), name, "Contract's `name` is not set or queried correctly.");
    
  });
  
  
  it("Has no voters initially", async() => {
    
    const [chance, amdin, project] = await createFixtures();
    
    const voters = await project.getVoters();
    console.log(voters);
    
  });
  
  // setVoters(), getVoters()
  it("Can specify voters", async() =>{
    const [chance, admin, project] = await createFixtures();
    
    const voters = chance.pickset(accounts, 3);
    console.log(voters);
    
    await project.assignVoters(voters);
    const voters2 = await project.getVoters(); 
    console.log(voters2);
   
    assert.isTrue(await voters2.map(v => voters.includes(v)).reduce((acc, cur) => acc && cur));
      
  });
  
  
  
});
