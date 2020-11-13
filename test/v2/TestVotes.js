const RegularERC20Token = artifacts.require("RegularERC20TokenL");
const ProjectManager = artifacts.require("ProjectManagerL");
const Votes = artifacts.require("VotesL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("'Votes' contract uint tests", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);

  
  const tokenContr = (async() => {
    return await RegularERC20Token.deployed();
  })();


  let tokenContr2;
  let prjMgrContr;
  let voteCntr;
  const votees = []; // fill in the `before` function
  const voters = []; // fill in the `before` function


  async function prepareFixtures(){
 
    const chance = new Chance();
    const admin = accounts[0];
    tokenContr2 = await RegularERC20Token.deployed();
    //const prjMgrCntr = await ProjectManager.deployed();
    //const votesCntr = await Votes.deployed();
    

    return [chance, admin];
  }
  
  async function printCurrentAccounts(title){
    const accts = votees.concat(voters);

    console.debug(tokenContr);
    //console.debug(tokenContr2);
    
    // query current balances
    for(const acct of votees){
      acct.balance = await tokenContr.balanceOf(acct.addr);
      acct.esv = web3.utils.fromWei(acct.balance);
    }    

    console.debug(title);
    console.table(accts);
  }
  
  before(async() => {   // before all hook
    assert.isAtLeast(accounts.length, 8, "There should at least 8 accounts to run this test.");
    
    const [chance, admin] = await prepareFixtures();
    
    
    for(const i of [0, 1, 2]){
      votees.push({no: i, title: `votee.${i}`, addr: accounts[3 + i], balance: 0, esv: ''});
      voters.push({no: i, title: `voter.${i}`, addr: accounts[6 + i], balance: 0, esv: ''});
    }
    
    await printCurrentAccounts(`Initiall token state.`)
  });
  
  it("Should have no project and a few reward models initially.", async() => {

  });
 
});