pragma solidity ^0.4.11;
/**
 * @title IDMoney
 * @dev Mintable ERC20 Token 
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 * Moneda base de IDPay para moneda aprobada por ID paises.
 */

import './token/MintableToken.sol';
import './crowdsale/CappedCrowdSale.sol';

contract IDMoney is MintableToken {
  string public name = "IDMONEY";
  string public symbol = "IDM";
  uint256 public decimals = 18; 
}

contract IDMCrowdsale is CappedCrowdsale {

  function IDMCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _goal, uint256 _cap, address _wallet)
    CappedCrowdsale(_cap)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
  {
    //As goal needs to be met for a successful crowdsale
    //the value needs to less or equal than a cap which is limit for accepted funds
    require(_goal <= _cap);
  }

  function createTokenContract() internal returns (IDMoney) {
    return new IDMoney();
  }

}
