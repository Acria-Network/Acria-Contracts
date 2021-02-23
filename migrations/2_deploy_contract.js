var AcriaMain = artifacts.require("AcriaMain");
var ExampleClient = artifacts.require("ExampleClient");

module.exports = function(deployer) {
    deployer.deploy(AcriaMain);
    deployer.deploy(ExampleClient);
};
