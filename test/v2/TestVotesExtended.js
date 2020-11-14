const RegularERC20Token = artifacts.require("RegularERC20TokenL");
const ProjectManager = artifacts.require("ProjectManagerL");
const Contributions = artifacts.require("ContributionsL");
const Votes = artifacts.require("VotesL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("'Votes' contract uint tests suite 2", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);
  
  let tokenContr, prjMgrContr, cntrbsContr, votesContr;
  
  const votees = []; // fill in the `before` function
  const voters = []; // fill in the `before` function

  async function prepareFixtures(){
    const chance = new Chance();
    const admin = accounts[0];

    return [chance, admin];
  }
  
  async function getAndPrintBalances(title){
    const bals = votees.concat(voters);
    bals.push({name: 'project manager', 
               addr: prjMgrContr.address, 
               amount: await tokenContr.balanceOf(prjMgrContr.address)});

    // query current balances
    for(const bal of bals){
      bal.amount = await tokenContr.balanceOf(bal.addr);
      bal.esv = web3.utils.fromWei(bal.amount);
    }    

    console.debug(`\n[[ ${title} ]]`);
    console.table(bals, ['name', 'addr', 'amount', 'esv']);
    
    return bals;
  }
  
  before(async() => {   // before all hook
    assert.isAtLeast(accounts.length, 8, "There should at least 8 accounts to run this test.");
    
    const [chance, admin] = await prepareFixtures();
    tokenContr = await RegularERC20Token.deployed();
    prjMgrContr = await ProjectManager.deployed();
    cntrbsContr = await Contributions.deployed();
    votesContr = await Votes.deployed();
    
    for(const i of [0, 1, 2]){
      votees.push({no: i, name: `votee.${i}`, addr: accounts[3 + i], balance: 0, esv: ''});
      voters.push({no: i, name: `voter.${i}`, addr: accounts[6 + i], balance: 0, esv: ''});
    }
    
    //await getAndPrintBalances(`Initiall Token Balances`)
  });
  
  it.skip("Can vote again or unvote.", async() => {
    
    const bals0 = await getAndPrintBalances(`Token Balances before Vote`);
    
    const [chance, admin] = await prepareFixtures();
    const rwdMdl = await prjMgrContr.getRewardModel(0);
    
    const epc = Date.now();
    const prj = {
      id: epc.toString().substring(3), 
      name: 'Prj 1', 
      totalReward: toBN(1E20),
      totalRewardESV: web3.utils.fromWei(toBN(1E20)),
      contribsPrct: 70,
      rewardMdlAddr: rwdMdl.addr
    }
    
    //const vtrs = [];
    //for(const vtr of voters) vtrs.push(vtr.address);
    // Create a new project
    await prjMgrContr.createProject(prj.id, prj.name, 
        prj.totalReward, prj.contribsPrct, prj.rewardMdlAddr, {from: admin});
    
    console.debug("\n[[ Project Created ]]");
    console.table(prj, ['Values']);
    
    // Assign 3 voters to the project 
    await prjMgrContr.assignProjectVoters(
        prj.id, voters.map(e => e.addr), {from: admin});
    
    // Query voters of the project
    const vtrs = await prjMgrContr.getProjectVoters(prj.id);
    const vtrs2 = [];
    for(const [i, vtr] of vtrs.entries()){
      vtrs2.push({project: prj.id, voter: voters.find(e => e.addr == vtrs[i]).name, voterAddr: vtrs[i]});         ;
    }
    
    console.debug("\n[[ Voters Assigned ]]");
    console.table(vtrs2);
    
    const cntrbs = [];
    for(const i of [0, 1]){
      cntrbs.push({project: prj.id, title: `Contrib ${i}`, 
          owner: votees[i].name, ownerAddr: votees[i].addr});
    }
    
    // Add 2 contributions to the project
    for(const cntrb of cntrbs){
      await cntrbsContr.addOrUpdateContribution(
        toBN(cntrb.project), cntrb.ownerAddr, cntrb.title, {from: admin});
    }
    
    console.log("\n[[ Contributions Registered ]]")
    console.table(cntrbs);
    
    // Create data to vote
    const vts0 = []; // votes to cast
    vts0.push({project: prj.id, voterAddr: voters[0].addr, 
        voteeAddr: cntrbs[0].ownerAddr, amount: toBN(3E18)});
    vts0.push({project: prj.id, voterAddr: voters[1].addr, 
        voteeAddr: cntrbs[0].ownerAddr, amount: toBN(3E18)});
    vts0.push({project: prj.id, voterAddr: voters[2].addr, 
        voteeAddr: cntrbs[1].ownerAddr, amount: toBN(4E18)});
    
    for(const vt0 of vts0){
      vt0.votee = votees.find(e => e.addr == vt0.voteeAddr).name;
      vt0.voter = voters.find(e => e.addr == vt0.voterAddr).name;
      vt0.esv = web3.utils.fromWei(vt0.amount);
    }

    console.debug("\n[[ Votes to Cast (before cast) ]]")
    console.table(vts0, ['project', 'voter', 'votee', 'esv']);
    
    // Approve token and cast vote
    for(const vt of vts0){
      await tokenContr.approve(prjMgrContr.address, vt.amount, {from: vt.voterAddr});
      await votesContr.vote(prj.id, vt.voteeAddr, vt.amount, {from: vt.voterAddr});  
    }
    
    // Query current votes and scores
    const vts1 = await votesContr.getVotesByProject(prj.id);
    const scrs1 = await votesContr.getScoresByProject(prj.id);
    
    // Verify queried votes and scores
    assert.sameMembers(vts1.map(e => e.voter), vts0.map(e => e.voterAddr));
    for(const vt1 of vts1){
      assert.isTrue(toBN(vt1.amount).eq(vts0.find(e => e.voterAddr == vt1.voter).amount));
    }
    assert.sameMembers(vts1.map(e => e.votee), vts0.map(e => e.voteeAddr));
    for(const scr1 of scrs1){
      let val = vts0.filter(e => e.voteeAddr == scr1.owner).reduce((acc, cur) => {return acc.add(cur.amount);}, toBN(0));
      assert.isTrue(toBN(scr1.value).eq(val));
    }
    console.log('Votes are verified');

    // Display queried votes and scores    
    const vts2 = []; // queried votes
    for(const vt1 of vts1){
      vts2.push({project: prj.id, voter: voters.find(e => e.addr == vt1.voter).name, 
          votee: votees.find(e => e.addr == vt1.votee).name, esv: web3.utils.fromWei(vt1.amount)});
    }
    console.debug("\n[[ Votes Queried ]]");
    console.table(vts2, ['project', 'voter', 'votee', 'esv']);
    const scrs2 = []
    for(const scr1 of scrs1){
      scrs2.push({project: prj.id, votee: votees.find(e => e.addr == scr1.owner).name,
          esv: web3.utils.fromWei(scr1.value)});
    }
    console.debug("\n[[ Scores Queried ]]");
    console.table(scrs2);
    
    // Get balances after votes
    const bals1 = await getAndPrintBalances('Balances after Vote');
    
    // Verfiy balances
    for(const bal1 of bals1){
      // balance before vote
      let amt = bals0.find(e => e.addr == bal1.addr).amount;  
      
      if(votees.includes(bal1.addr)){  
        // for votee, balance is expected not to be changed
        assert.isTrue(bal1.amount.eq(amt)); 
      }else if(voters.includes(bal1.addr)){
        assert.isTrue(bal1.amount.sub(vts0.find(e => e.voterAddr == bal1.addr).amount).eq(amt));
      }else if(bal1.name == 'project manager'){
        // sum of votes amounts
        let sm = vts0.reduce((acc, cur) => {return acc.add(cur.amount);}, toBN(0));
        assert.isTrue(bal1.amount.eq(amt.add(sm)));
      }
    }
    console.log('Balances are verified');
    

  });
 
});