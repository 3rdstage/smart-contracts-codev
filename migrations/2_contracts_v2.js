const RegularERC20Token = artifacts.require("RegularERC20TokenL");
const ProjectManager = artifacts.require("ProjectManagerL");
const ProportionalRewardModel = artifacts.require("ProportionalRewardModelL");
const EvenVoterRewardModel = artifacts.require("EvenVoterRewardModelL");
const WinnerTakesAllModel = artifacts.require("WinnerTakesAllModelL");
//const Top2RewardedModel = artifacts.require("Top2RewardedModelL");
const Contributions = artifacts.require("ContributionsL");
const Votes = artifacts.require("VotesL");


module.exports = async function (deployer, network, accounts) {
  'use strict';
  
  console.debug('Starting to deploy 8 contracts');
  const startAt = Date.now();
  const admin = accounts[0];
  const options = {from: admin, overwrite: true};

  console.debug("Deploying 'Token' contract.");
  await deployer.deploy(RegularERC20Token, "Environment Social Value Token", "ESV", options);
  
  console.debug("Deploying 'Project Manager' contract and 3 'Reward Model' contracts.")
  await deployer.deploy(ProjectManager, RegularERC20Token.address, options);
  await deployer.deploy(ProportionalRewardModel, 15, 10, options);
  await deployer.deploy(EvenVoterRewardModel, options);
  await deployer.deploy(WinnerTakesAllModel, options);

  console.debug("Granting token minter role to project manager")
  const tkn = await RegularERC20Token.deployed();
  await tkn.grantRole(await tkn.MINTER_ROLE(), ProjectManager.address);
  console.debug("Registering 3 reward models to project manager");
  const mdlAddrs = [
      ProportionalRewardModel.address, 
      EvenVoterRewardModel.address,
      WinnerTakesAllModel.address
  ];
  const prjMgr = await ProjectManager.deployed();
  await prjMgr.registerRewardModels(mdlAddrs, options);
  
  console.debug("Deploying 'Contributions' contract and 'Votes' contract.");
  await deployer.deploy(Contributions, ProjectManager.address, options);
  
  await deployer.deploy(Votes, ProjectManager.address, Contributions.address, options);
  const vts = await Votes.deployed();
  await prjMgr.setVotesContact(Votes.address);
  
  console.debug("Mining initial balances to 3 voters");
  for(const i of [6, 7, 8]){
    await tkn.mint(accounts[i], web3.utils.toBN(50E18), options);
  }
  
  const mdlCnt = await prjMgr.getNumberOfRewardModels();
  console.debug(`Number of registered reward models: ${mdlCnt}`);
  console.debug(`Finished contract deployment : ${Date.now() - startAt} milli-sec elapsed`);

};



const alternative = function (deployer, network, accounts) {
  'use strict';
  
  console.debug('Starting to deploy 7 contracts');
  const startAt = Date.now();
  const admin = accounts[0];
  const options = {from: admin, overwrite: true};
  const tknName = "Environment Social Value Token";
  const tknSymb = "ESV";
  
  let tknCntr = 0, prjMgrCntr = 0, cntrbsCntr = 0, vtsCntr = 0;
  
  console.debug("Deploying 'Token' contract.");
  deployer.deploy(RegularERC20Token, tknName, tknSymb, options).then(function(deployed){
    tknCntr = deployed;
    console.debug("Deploying 'Project Manager' contract.")
    
    return deployer.deploy(ProjectManager, RegularERC20Token.address, options);
  }).then(function(deployed){
    prjMgrCntr = deployed;
    
    return tknCntr.MINTER_ROLE();
  }).then(function(role){
    console.debug("Registering 3 reward models to project manager");
    
    return tknCntr.grantRole(role, ProjectManager.address, options);
  }).then(function(){
    console.debug("Deploying 3 'Reward Model' contracts.")
    
    return deployer.deploy(ProportionalRewardModel, 15, 10, options);
  }).then(function(deployed){
    
    return deployer.deploy(EvenVoterRewardModel, options);
  }).then(function(deployed){
    
    return deployer.deploy(WinnerTakesAllModel, options);
  }).then(function(deployed){
    console.debug("Registering 3 reward models to project manager");
    
    const mdlAddrs = [
        ProportionalRewardModel.address, 
        EvenVoterRewardModel.address,
        WinnerTakesAllModel.address
    ];
        
    return prjMgrCntr.registerRewardModels(mdlAddrs, options);
  }).then(function(){
    console.debug("Deploying 'Contributions' contract and 'Votes' contract.");
    
    return deployer.deploy(Contributions, ProjectManager.address, options);
  }).then(function(deployed){
    cntrbsCntr = deployed;
    
    return deployer.deploy(Votes, ProjectManager.address, Contributions.address, options);
  }).then(function(deployed){
    vtsCntr = deployed;
    
    return prjMgrCntr.setVotesContact(Votes.address);
  }).then(function(deployed){
    console.debug("Mining initial balances to 3 voters");
    
    return tknCntr.mint(accounts[6], web3.utils.toBN(50E18), options);
  }).then(function(deployed){
    
    return tknCntr.mint(accounts[7], web3.utils.toBN(50E18), options);
  }).then(function(deployed){
    
    return tknCntr.mint(accounts[8], web3.utils.toBN(50E18), options);
  }).then(function(){
    return prjMgrCntr.getNumberOfRewardModels();
    
  }).then(function(cnt){
    console.debug(`Number of registered reward models: ${cnt}`);
    console.debug(`Finished contract deployment : ${Date.now() - startAt} milli-sec elapsed`);
    return;
  })

};