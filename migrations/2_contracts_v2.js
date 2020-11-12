const Migrations = artifacts.require("Migrations");
const ProjectManager = artifacts.require("ProjectManagerL");
const ProportionalRewardModel = artifacts.require("ProportionalRewardModelL");
const EvenVoterRewardModel = artifacts.require("EvenVoterRewardModelL");
const Top2RewardedModel = artifacts.require("Top2RewardedModelL");
const WinnerTakesAllModel = artifacts.require("WinnerTakesAllModelL");
const Contributions = artifacts.require("ContributionsL");
const Votes = artifacts.require("VotesL");

module.exports = async function (deployer, network, accounts) {
  
  const admin = accounts[0];

  // `ProjectManager` contract and `IRewardModel` implementation contracts  
  await deployer.deploy(ProjectManager, {from: admin});
  await deployer.deploy(ProportionalRewardModel, 15, 10, {from: admin});
  await deployer.deploy(EvenVoterRewardModel, {from: admin});
  await deployer.deploy(Top2RewardedModel, {from: admin});
  await deployer.deploy(WinnerTakesAllModel, {from: admin});
  
  const prjMgr = await ProjectManager.deployed();
  const propMdl = await ProportionalRewardModel.deployed();
  const evenMdl = await EvenVoterRewardModel.deployed();
  const top2Mdl = await Top2RewardedModel.deployed();
  const winnerMdl = await WinnerTakesAllModel.deployed();
  
  await prjMgr.registerRewardModel(propMdl.address, {from: admin});
  await prjMgr.registerRewardModel(evenMdl.address, {from: admin});
  await prjMgr.registerRewardModel(top2Mdl.address, {from: admin});
  await prjMgr.registerRewardModel(winnerMdl.address, {from: admin});
  
  // `Contributions` contract
  await deployer.deploy(Contributions, prjMgr.address, {from: admin});
  const contribs = await Contributions.deployed();
  
  // `Votes` contract
  await deployer.deploy(Votes, prjMgr.address, contribs.address, {from: admin});
  const vts = await Votes.deployed();
  await prjMgr.setVotesContact(vts.address);
  
  
  const mdlCnt = await prjMgr.getNumberOfRewardModels();
  console.log(`Number of registered reward models: ${mdlCnt}`);

};