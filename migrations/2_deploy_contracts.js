var ProjectFactory = artifacts.require("./ProjectFactory.sol");
var Token = artifacts.require("./ERC20PresetMinterPauser.sol");

module.exports = function(deployer) {
  deployer.deploy(Token, 'Esv', 'ESV', {from: "0x42993c13FE81Ae4695dCCd6d62915933abfB9C22"}).then(function(){
    return deployer.deploy(ProjectFactory, Token.address);
 });
};
