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
    const votes = [];
    
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
      prj.voters = vtrs.toString();
    }

    console.log("Voters Assigned");
    console.table(projects, ['id', 'voters']);
    
    // Register 2 contributions to the first project
    contribs.push({project: projects[0].id, contributor: contributors[0], title: "C1"});
    contribs.push({project: projects[0].id, contributor: contributors[1], title: "C2"});
    
    for(const cntr of contribs){
      expectEvent(
        await contribsContr.addOrUpdateContribution(toBN(cntr.project), cntr.contributor, cntr.title, {from: admin}),
        'ContributionAdded', {0: toBN(cntr.project), 1: cntr.contributor});
    }
    console.log("Contributions Registered");
    console.table(contribs);
    
    // Vote on the first project
    votes.push({project: projects[0].id, voter: voters[0], votee: contributors[0], amount: 4E18});
    votes.push({project: projects[0].id, voter: voters[1], votee: contributors[0], amount: 5E18});
    votes.push({project: projects[0].id, voter: voters[2], votee: contributors[1], amount: 6E18});
    
    for(const vt of votes){
      expectEvent(
        await votesContr.vote(toBN(vt.project), vt.votee, toBN(vt.amount), {from: vt.voter}),
        'Voted', {0: toBN(vt.project), 1: vt.voter, 2: vt.votee, 3: toBN(vt.amount)});
    }
    console.log("First Project Voted");
    console.table(votes);


    
  });
});






