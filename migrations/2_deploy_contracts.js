//var ConvertLib = artifacts.require("./ConvertLib.sol");
//var MetaCoin = artifacts.require("./MetaCoin.sol");
var IDMoney = artifacts.require("./IDMoney.sol");

module.exports = function(deployer) {
//  deployer.deploy(ConvertLib);
//  deployer.link(ConvertLib, MetaCoin);
//  deployer.deploy(MetaCoin);
  deployer.deploy(IDMoney);
};
