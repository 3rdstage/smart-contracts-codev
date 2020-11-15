const RegularERC20Token = artifacts.require("RegularERC20TokenL");
const ProjectManager = artifacts.require("ProjectManagerL");
const Contributions = artifacts.require("ContributionsL");
const Votes = artifacts.require("VotesL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("Integrated test including vote, reward simulation and reward distribution.", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);
  
  let tokenContr, prjMgrContr, cntrbsContr, votesContr;
  
  const votees = []; // fill in the `before` function
  const voters = []; // fill in the `before` function

  async function prepareFixtures(){
    const chance = new Chance();
    const admin = accounts[0];
    const formatter = new Intl.NumberFormat('en')

    return [chance, admin, formatter];
  }
  
  async function getAndPrintBalances(title, verbose = false){
    const bals = votees.concat(voters);
    bals.push({name: 'project manager', 
               addr: prjMgrContr.address, 
               amount: await tokenContr.balanceOf(prjMgrContr.address)});

    // query current balances
    const nf = new Intl.NumberFormat('en')
    for(const bal of bals){
      bal.amount = await tokenContr.balanceOf(bal.addr);
      bal.wei = nf.format(bal.amount.toString());
      bal.esv = web3.utils.fromWei(bal.amount);
    }    

    if(verbose){
      console.debug(`\n[[ ${title} ]]`);
      console.table(bals, ['name', 'addr', 'wei', 'esv']);
    }
    
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
  
  async function executeScenario(prj, vteeAddrs, vts, vtTitle, verbose = false){
    
    const [chance, admin, formatter] = await prepareFixtures();
    
    if(verbose){
      let hr = '#'.repeat(vtTitle.length + 12)
      console.warn(`${hr}\n###   ${vtTitle}   ###\n${hr}`);
    }
    
    const bals0 = await getAndPrintBalances(`Token Balances before Vote`, verbose);
    
    // Create a new project
    await prjMgrContr.createProject(prj.id, prj.name, 
        prj.totalReward, prj.contribsPrct, prj.rewardMdlAddr, {from: admin});
    
    if(verbose){
      prj.reward = formatter.format(web3.utils.fromWei(prj.totalReward));
      const prjs = [prj];
      console.log("\n[[ Project Created ]]");
      console.table(prjs, ['id', 'reward', 'contribsPrct']);
    }
    
    // Assign voters to the project 
    await prjMgrContr.assignProjectVoters(prj.id, vts.map(e => e.voterAddr), {from: admin});
    
    // Query voters of the project
    const vtrs = await prjMgrContr.getProjectVoters(prj.id);
    const vtrs2 = [];
    for(const [i, vtr] of vtrs.entries()){
      vtrs2.push({project: prj.id, voter: voters.find(e => e.addr == vtrs[i]).name, voterAddr: vtrs[i]});         ;
    }
    
    if(verbose){
      console.log("\n[[ Voters Assigned ]]");
      console.table(vtrs2);
    }
    
    const cntrbs = [];
    for(const [i, addr] of vteeAddrs.entries()){
      cntrbs.push({project: prj.id, title: `Contrib ${i}`, 
          owner: votees.find(e => e.addr == addr).name, ownerAddr: addr});
    }
    
    // Add contributions to the project
    for(const cntrb of cntrbs){
      await cntrbsContr.addOrUpdateContribution(
        toBN(cntrb.project), cntrb.ownerAddr, cntrb.title, {from: admin});
    }
    
    if(verbose){
      console.log("\n[[ Contributions Registered ]]")
      console.table(cntrbs);
    }
    
    // Create data to vote
    const vts0 = vts; // votes to cast
    for(const vt0 of vts0){
      vt0.project = prj.id;
      vt0.votee = votees.find(e => e.addr == vt0.voteeAddr).name;
      vt0.voter = voters.find(e => e.addr == vt0.voterAddr).name;
      vt0.esv = web3.utils.fromWei(vt0.amount);
    }

    if(verbose){
      console.log("\n[[ Votes to Cast (before cast) ]]")
      console.table(vts0, ['project', 'voter', 'votee', 'esv']);
    }
    
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
    if(verbose) console.log('Votes are verified');

    // Display queried votes and scores    
    const vts2 = []; // queried votes
    for(const vt1 of vts1){
      vts2.push({project: prj.id, voter: voters.find(e => e.addr == vt1.voter).name, 
          votee: votees.find(e => e.addr == vt1.votee).name, esv: web3.utils.fromWei(vt1.amount)});
    }
    if(verbose){
      console.log("\n[[ Votes Queried ]]");
      console.table(vts2, ['project', 'voter', 'votee', 'esv']);
    }
    
    const scrs2 = []
    for(const scr1 of scrs1){
      scrs2.push({project: prj.id, votee: votees.find(e => e.addr == scr1.owner).name,
          esv: web3.utils.fromWei(scr1.value)});
    }
    if(verbose){
      console.log("\n[[ Scores Queried ]]");
      console.table(scrs2);
    }
    
    // Get balances after votes
    const bals1 = await getAndPrintBalances('Balances after Vote', verbose);
    
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
    if(verbose) console.log('Balances are verified');
    
    
    const rslt = await prjMgrContr.simulateRewardsArrayRetuns(prj.id);
    const rwds = [];
    
    let amt = 0;
    for(const [i, vtee] of rslt.votees.entries()){
      amt = rslt.voteeRewards[i];
      rwds.push({name: votees.find(e => e.addr == vtee).name, addr: vtee, 
        amount: formatter.format(amt), esv: web3.utils.fromWei(amt)});
    }
    for(const [i, vter] of rslt.voters.entries()){
      amt = rslt.voterRewards[i];
      rwds.push({name: voters.find(e => e.addr == vter).name, addr: vter,
        amount: formatter.format(amt), esv: web3.utils.fromWei(amt)});
    }
    rwds.sort(function(e1, e2){
      const n1 = e1.name, n2 = e2.name;
      if(n1 > n2){ return 1; }else if(n1 < n2){ return -1; }else{ return 0; }
    })
    
    rwds.push({name: 'remainder', amount: formatter.format(rslt.remainder), esv: web3.utils.fromWei(rslt.remainder)});
    
    if(verbose){
      console.log("\n[[ Rewards Simulated ]]");
      console.table(rwds, ['addr', 'name', 'amount', 'esv']);
    }
    
    return rwds;
  }
  
  
  it("Can follow corretly the 1st scenario of which contest defined.", async() => {
    
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
    
    const vteeAddrs = [ votees[0].addr, votees[1].addr ];
    const vts = [];
    vts.push({voterAddr: voters[0].addr, voteeAddr: vteeAddrs[0], amount: toBN(3E18)});
    vts.push({voterAddr: voters[1].addr, voteeAddr: vteeAddrs[0], amount: toBN(3E18)});
    vts.push({voterAddr: voters[2].addr, voteeAddr: vteeAddrs[1], amount: toBN(4E18)});
 
    const rwds = await executeScenario(prj, vteeAddrs, vts, "Scenario 1 (Contest Scenario)", true);
    
    /*
     * Expected rewards
     *
     *   votee.0 : 42 ESV        votee.1 : 28 ESV 
     *   voter.0 : 10.3846 ESV   voter.1 : 10.3846 ESV   voter.2 : 9.2308   
     */
    assert.equal(rwds.find(e => e.addr == votees[0].addr).esv, 42);
    assert.equal(rwds.find(e => e.addr == votees[1].addr).esv, 28);
    assert.approximately(Number.parseFloat(rwds.find(e => e.addr == voters[0].addr).esv), 10.38, 0.01);
    assert.approximately(Number.parseFloat(rwds.find(e => e.addr == voters[1].addr).esv), 10.38, 0.01);
    assert.approximately(Number.parseFloat(rwds.find(e => e.addr == voters[2].addr).esv), 9.23, 0.01);
    
    // verify total reward
    assert.approximately(rwds.reduce((acc, cur) => { return acc + Number.parseFloat(cur.esv); }, 0), 100, 0.01);
    console.log("Simulated rewards are verified.");
        
  });
  
  it("Can follow corretly the 2nd scenario.", async() => {
    
    const [chance, admin] = await prepareFixtures();
    const rwdMdl = await prjMgrContr.getRewardModel(0);
    
    const epc = Date.now();
    const prj = {
      id: epc.toString().substring(3), 
      name: 'Prj 2', 
      totalReward: toBN(1E20),
      totalRewardESV: web3.utils.fromWei(toBN(1E20)),
      contribsPrct: 70,
      rewardMdlAddr: rwdMdl.addr
    }
    
    const vteeAddrs = [ votees[0].addr, votees[1].addr ];
    const vts = [];
    vts.push({voterAddr: voters[0].addr, voteeAddr: vteeAddrs[0], amount: toBN(3E18)});
    vts.push({voterAddr: voters[1].addr, voteeAddr: vteeAddrs[0], amount: toBN(3E18)});
    vts.push({voterAddr: voters[2].addr, voteeAddr: vteeAddrs[1], amount: toBN(6E18)});
 
    const rwds = await executeScenario(prj, vteeAddrs, vts, "Scenario 2", true); 
    
    /*
     * Expected rewards
     *
     *   votee.0 : 35 ESV    votee.1 : 35 ESV 
     *   voter.0 : 7.5 ESV   voter.1 : 7.5 ESV   voter.2 : 15 ESV  
     */
    assert.equal(rwds.find(e => e.addr == votees[0].addr).esv, 35);
    assert.equal(rwds.find(e => e.addr == votees[1].addr).esv, 35);
    assert.equal(rwds.find(e => e.addr == voters[0].addr).esv, 7.5);
    assert.equal(rwds.find(e => e.addr == voters[1].addr).esv, 7.5);
    assert.equal(rwds.find(e => e.addr == voters[2].addr).esv, 15);
    assert.equal(rwds.find(e => e.name == 'remainder').amount, 0);  // 0 remainer
    
    // verify total reward
    assert.approximately(rwds.reduce((acc, cur) => { return acc + Number.parseFloat(cur.esv); }, 0), 100, 0.01);
    console.log("Simulated rewards are verified.");
        
  });
  
  it("Can vote according to scenario 3", async() => {
    
    const [chance, admin] = await prepareFixtures();
    const rwdMdl = await prjMgrContr.getRewardModel(0);
    
    const epc = Date.now();
    const prj = {
      id: epc.toString().substring(3), 
      name: 'Prj 3', 
      totalReward: toBN(1E20),
      totalRewardESV: web3.utils.fromWei(toBN(1E20)),
      contribsPrct: 70,
      rewardMdlAddr: rwdMdl.addr
    }
    
    const vteeAddrs = [ votees[0].addr, votees[1].addr ];
    const vts = [];
    vts.push({voterAddr: voters[0].addr, voteeAddr: vteeAddrs[0], amount: toBN(3E18)});
    vts.push({voterAddr: voters[1].addr, voteeAddr: vteeAddrs[0], amount: toBN(3E18)});
    vts.push({voterAddr: voters[2].addr, voteeAddr: vteeAddrs[0], amount: toBN(4E18)});
 
    const rwds = await executeScenario(prj, vteeAddrs, vts, "Scenario 3", true); 
    
    /*
     * Expected rewards
     *
     *   votee.0 : 70 ESV   votee.1 : 0 ESV 
     *   voter.0 : 9 ESV    voter.1 : 9 ESV   voter.2 : 12 ESVß   
     */
    assert.equal(rwds.find(e => e.addr == votees[0].addr).esv, 70);
    //assert.equal(rwds.find(e => e.addr == votees[1].addr).esv, 0);
    assert.equal(rwds.find(e => e.addr == voters[0].addr).esv, 9);
    assert.equal(rwds.find(e => e.addr == voters[1].addr).esv, 9);
    assert.equal(rwds.find(e => e.addr == voters[2].addr).esv, 12);
    assert.equal(rwds.find(e => e.name == 'remainder').amount, 0);  // 0 remainer
    
    // verify total reward
    assert.approximately(rwds.reduce((acc, cur) => { return acc + Number.parseFloat(cur.esv); }, 0), 100, 0.01);
    console.log("Simulated rewards are verified.");
        
  });  
  
  it("Can vote according to scenario 4", async() => {
    
    const [chance, admin] = await prepareFixtures();
    const rwdMdl = await prjMgrContr.getRewardModel(0);
    
    const epc = Date.now();
    const prj = {
      id: epc.toString().substring(3), 
      name: 'Prj 4', 
      totalReward: toBN(1E20),
      totalRewardESV: web3.utils.fromWei(toBN(1E20)),
      contribsPrct: 70,
      rewardMdlAddr: rwdMdl.addr
    }
    
    const vteeAddrs = [ votees[0].addr, votees[1].addr, votees[2].addr ];
    const vts = [];
    vts.push({voterAddr: voters[0].addr, voteeAddr: vteeAddrs[1], amount: toBN(7E18)});
    vts.push({voterAddr: voters[1].addr, voteeAddr: vteeAddrs[2], amount: toBN(3E18)});
    vts.push({voterAddr: voters[2].addr, voteeAddr: vteeAddrs[0], amount: toBN(4E18)});
 
    const rwds = await executeScenario(prj, vteeAddrs, vts, "Scenario 4", true); 
    
    /*
     * Expected rewards
     *
     *   votee.0 : 20 ESV   votee.1 : 35 ESV        votee.2 : 15 ESV 
     *   voter.0 : 18 ESV   voter.1 : 5.1429 ESV    voter.2 : 6.8571 ESV
     */
    assert.equal(rwds.find(e => e.addr == votees[0].addr).esv, 20);
    assert.equal(rwds.find(e => e.addr == votees[1].addr).esv, 35);
    assert.equal(rwds.find(e => e.addr == votees[2].addr).esv, 15);
    assert.equal(rwds.find(e => e.addr == voters[0].addr).esv, 18);
    assert.approximately(Number.parseFloat(rwds.find(e => e.addr == voters[1].addr).esv), 5.14, 0.01);
    assert.approximately(Number.parseFloat(rwds.find(e => e.addr == voters[2].addr).esv), 6.85, 0.01);
    
    // verify total reward
    assert.approximately(rwds.reduce((acc, cur) => { return acc + Number.parseFloat(cur.esv); }, 0), 100, 0.01);
    console.log("Simulated rewards are verified.");
  });    
 
});