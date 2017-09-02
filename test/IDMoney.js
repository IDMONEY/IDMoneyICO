var IDMoney = artifacts.require("./IDMoney.sol");

contract('IDMoney', function(accounts) {
  it("balance should be 0 at beginning", function() {
    return IDMoney.deployed().then(function(instance) {
      return instance.balanceOf.call(accounts[0]);
    }).then(function(balance) {
      assert.equal(balance.valueOf(), 0, "0 is not the balance");
    });
  });
});
