const RegularERC20Token = artifacts.require("RegularERC20TokenL");
const ProjectManagerContract = artifacts.require("ProjectManagerL");
const ProjectContract = artifacts.require("ProjectL");
const ContributionsContract = artifacts.require("ContributionsL");
const VotesContract = artifacts.require("VotesL");
const IRewardModelContract = artifacts.require("IRewardModelL");
const EvenVoterRewardModelContract = artifacts.require("EvenVoterRewardModelL");
const ProportionalRewardModelContract = artifacts.require("ProportionalRewardModelL");
const WinnerTakesAllModelContract = artifacts.require("WinnerTakesAllModelL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("Integrated test for normal scenario", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);

  const EventNames = { };

  async function prepareFixtures(deployed = false){
    const chance = new Chance();
    const admin = (deployed) ? accounts[0] : chance.pickone(accounts);
 
    return [chance, admin];
  }
  
  async function displayBalances(tknContr, admin, prjMgr, vtees, vters){
    
    const bals = [];
    
    bals.push({title: 'admin', address: admin, balance: await tknContr.balanceOf(admin)});
    bals.push({title: 'project manager contract', 
               address: prjMgr.address, balance: await tknContr.balanceOf(prjMgr.address)});
               
    for(const [i, vtee] of vtees.entries()){
      bals.push({title: `votee.${i}`, address: vtee, 
                 balance: (await tknContr.balanceOf(vtee)).toLocaleString()});
    }
    
    for(const [i, vter] of vters.entries()){
      bals.push({title: `voter.${i}`, address: vter, 
                 balance: (await tknContr.balanceOf(vter)).toLocaleString()});
    }
    
    console.debug(`Current token balances`);
    console.table(bals);    
  }
  
  before(async() => {
    
    const accts = [];
    let balance = 0;

    for(const acct of accounts){
        await accts.push([acct, await web3.eth.getBalance(acct)]);
    }

    console.debug(`The number of accounts : ${accounts.length}`);
    console.table(accts);
  });
 
  
  it("Can follow normal scenario", async() => {
    const chance = new Chance();
    const admin = accounts[0];
    const contributors = [accounts[3], accounts[4], accounts[5]];
    const voters = [accounts[6], accounts[7], accounts[8]];
    const projects = []; // fill later
    const contribs = []; // fill later
    const votes = []; // fill later
    const rwdMdlContrs = []; // reward model contracts, fill right below
    const cntrAddrs = {}; // fill later

    // Identify contracts    
    rwdMdlContrs.push(await ProportionalRewardModelContract.deployed());
    rwdMdlContrs.push(await EvenVoterRewardModelContract.deployed());
    rwdMdlContrs.push(await WinnerTakesAllModelContract.deployed());
    
    const tknContr = await RegularERC20Token.deployed();
    const prjMgrContr = await ProjectManagerContract.deployed();
    const contribsContr = await ContributionsContract.deployed();
    const votesContr = await VotesContract.deployed();
    
    cntrAddrs.Token = tknContr.address;
    cntrAddrs.ProjectManager = prjMgrContr.address;
    cntrAddrs.Contributions = contribsContr.address;
    cntrAddrs.Votes = votesContr.address;
    
    console.log("Smart Contract Addresses");
    console.table(cntrAddrs);
    
    // Setup 

    // Mint tokens to voters, if necessary
    for(const vter of voters){
      if((await tknContr.balanceOf(vter)).lt(toBN(50E18))){
        tknContr.mint(vter, toBN(50E18), {from: admin});
      }
    }
    await displayBalances(tknContr, admin, prjMgrContr, contributors, voters)
  
    // Create 2 projects
    const epc = Date.now();
    projects.push({id: epc.toString().substring(3), name: 'p1', totalReward: toBN(1E20), 
        totalRewardStr: '1E20', contribPrct: 70, rewardModelAddr: rwdMdlContrs[0].address});
    projects.push({id: (epc + 1).toString().substring(3), name: 'p2', totalReward: toBN(2E20), 
        totalRewardStr: '2E20', contribPrct: 80, rewardModelAddr: rwdMdlContrs[0].address});
    let result = null, prjId = 0, ev = null;
    for(const prj of projects){
      result = await prjMgrContr.createProject(
          prj.id, prj.name, prj.totalReward, prj.contribPrct, prj.rewardModelAddr, {from: admin});
      expectEvent(result, 'ProjectCreated');
      ev = result.logs[0].args;
      assert.equal(prj.id, ev.id);
      prj.address = ev.addr;
    }
    console.log(`Created ${projects.length} Projects`);
    console.table(projects, ['id', 'address', 'name', 'totalRewardStr', 'contribPrct']);
    
    // Assign voters - all 3 voters for all projects
    let prjContr = 0;
    for(const prj of projects){
      await prjMgrContr.assignProjectVoters(prj.id, voters, {from: admin});
      prjContr = await ProjectContract.at(prj.address);

      assert.sameMembers(await prjContr.getVoters(), voters, `Voters for the project ${prj.id} has NOT been set correctly.`);
      prj.voters = voters.toString();
    }

    console.log("Voters Assigned");
    console.table(projects, ['id', 'voters']);
    
    // Register 2 contributions to the first project
    contribs.push({project: projects[0].id, contributor: contributors[0], title: "C1"});
    contribs.push({project: projects[0].id, contributor: contributors[1], title: "C2"});
    
    for(const cntrb of contribs){
      expectEvent(
        await contribsContr.addOrUpdateContribution(toBN(cntrb.project), cntrb.contributor, cntrb.title, {from: admin}),
        'ContributionAdded', {0: toBN(cntrb.project), 1: cntrb.contributor});
    }
    console.log("Contributions Registered");
    console.table(contribs);
    
    // Vote on the first project
    votes.push({project: projects[0].id, voter: voters[0], votee: contributors[0], amount: 4E18});
    votes.push({project: projects[0].id, voter: voters[1], votee: contributors[0], amount: 4E18});
    votes.push({project: projects[0].id, voter: voters[2], votee: contributors[1], amount: 6E18});
    
    for(const vt of votes){
      tknContr.approve(prjMgrContr.address, toBN(vt.amount), {from: vt.voter});
      expectEvent(
        await votesContr.vote(toBN(vt.project), vt.votee, toBN(vt.amount), {from: vt.voter}),
        'Voted', {0: toBN(vt.project), 1: vt.voter, 2: vt.votee, 3: toBN(vt.amount)});
    }
    console.log("First Project Voted");
    console.table(votes);
    
    await displayBalances(tknContr, admin, prjMgrContr, contributors, voters)

  });
});






