var IDMoney = artifacts.require("./IDMoney.sol");

contract('IDMoney', function(accounts) {
  it("balance should be 0 at beginning", function() {
    return IDMoney.deployed().then(function(instance) {
      return instance.balanceOf.call(accounts[0]);
    }).then(function(balance) {
      //console.log('balance: '+balance.valueOf());
      assert.equal(balance.valueOf(), 0, "0 is not the balance");
    });
  });
  it("name should be IDMONEY", function() {
    return IDMoney.deployed().then(function(instance) {
      return instance.name.call();
    }).then(function(name) {
      //console.log('name: '+name);
      assert.equal(name, "IDMONEY", "IDMONEY is not the name");
    });
  });
  it("symbol should be IDM", function() {
    return IDMoney.deployed().then(function(instance) {
      return instance.symbol.call();
    }).then(function(symbol) {
      //console.log('symbol: '+symbol);
      assert.equal(symbol, "IDM", "IDM is not the symbol");
    });
  });
  it("contract state should be 1 (notICO)", function() {
    return IDMoney.deployed().then(function(instance) {
      return instance.state.call();
    }).then(function(state) {
      //console.log('state: '+state);
      assert.equal(state, 1, "state is not NotICO");
    });
  });
});

