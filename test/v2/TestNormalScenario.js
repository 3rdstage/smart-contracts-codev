const ProjectManagerContract = artifacts.require("ProjectManagerL");
const ProjectContract = artifacts.require("ProjectL");
const ContributionsContract = artifacts.require("ContributionsL");
const VotesContract = artifacts.require("VotesL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("Integrated test for normal scenario", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);

  const EventNames = {
  };

  async function createFixtures(){
    const chance = new Chance();
    const admin = chance.pickone(accounts);

    return [chance, admin];
  }
  
  before(async() => {
    
    assert.isAtLeast(accounts.length, 8, "There should at least 8 accounts to run this test.");
    
    const table = [];
    let balance = 0;

    for(const acct of accounts){
        await web3.eth.personal.unlockAccount(acct);
        await table.push([acct, await web3.eth.getBalance(acct)]);
    }

    console.debug(`The number of accounts : ${accounts.length}`);
    console.table(table);
  });
  
  
  it("Can follow normal scenario", async() => {
    const chance = new Chance();
    const admin = accounts[0];
    const contributors = [accounts[2], accounts[3], accounts[4]];
    const voters = [accounts[5], accounts[6], accounts[7]];
    const contractAddrs = {};
    const projects = [];
    const contribs = [];
    
    // Deploy Conracts
    const prjMgrContr = await ProjectManagerContract.new({from: admin});  
    const contribsContr = await ContributionsContract.new(prjMgrContr.address, {from: admin});
    const votesContr = await VotesContract.new(prjMgrContr.address, contribsContr.address, {from: admin});
    
    contractAddrs.ProjectManager = prjMgrContr.address;
    contractAddrs.Contributions = contribsContr.address;
    contractAddrs.Votes = votesContr.address;
    
    console.log("Smart Contract Addresses");
    console.table(contractAddrs);

    
    // Check initial state
    assert.isTrue((await prjMgrContr.getNumberOfProjects()).eqn(0), "initially there should be no project yet.");

  
    // Setup initial data  
    // Create 2 projects
    let result = null, ev = null;
    for(const p in ["p1", "p2"]){
      result = await prjMgrContr.createProject(p, {from: admin});
      
      expectEvent(result, 'ProjectCreated');
      
      ev = result.logs[0].args;
      projects.push({'id': ev.id.toNumber(), 'address': ev.addr});
    }
    console.log("Created Projects");
    console.table(projects, ['id', 'address']);
    
    // Assign voters
    let prjContr = 0, vtrs = [];
    for(const prj of projects){
      prjContr = await ProjectContract.at(prj.address);
      await prjContr.assignVoters(voters, {from: admin});
      vtrs = await prjContr.getVoters();

      assert.sameMembers(vtrs, voters, `Voters for the project ${prj.id} has NOT been set correctly.`);
      prj.voters = vtrs;
    }

    console.log("Voters Assigned");
    console.table(projects, ['id', 'voters']);
    
    // add 2 contributions to the first project
    expectEvent(
      await contribsContr.addOrUpdateContribution(toBN(projects[0].id), contributors[0], "C1", {from: admin}),
      'ContributionAdded', {0: toBN(projects[0].id), 1: contributors[0]});
    contribs.push({projectId: projects[0].id, contributor: contributors[0], title: "C1"});
    
    expectEvent(
      await contribsContr.addOrUpdateContribution(toBN(projects[0].id), contributors[1], "C2", {from: admin}),
      'ContributionAdded', {0: toBN(projects[0].id), 1: contributors[1]});
    contribs.push({projectId: projects[0].id, contributor: contributors[0], title: "C1"});
    
    console.log("Contributions Registered");
    console.table(contribs);
    
    // vote for the first project
    expectEvent(
      await votesContr.vote(toBN(projects[0].id), contributors[0], toBN(4E18), {from: voters[0]}),
      'Voted', {0: toBN(projects[0].id), 1: voters[0], 2: contributors[0], 3: 4E18});


    console.table(contributions); 
    
  });
});






