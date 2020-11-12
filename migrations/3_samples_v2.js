const SampleContract = artifacts.require("SampleL");

module.exports = function (deployer, network, accounts) {
  
  const admin = accounts[0];

  deployer.deploy(SampleContract, {from: admin});

}