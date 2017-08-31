pragma solidity ^0.4.11;
/**
 * @title IDMoney
 * @dev Mintable ERC20 Token 
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 * Moneda base de IDPay para moneda aprobada por ID paises.
 */

import './token/MintableToken.sol';

contract IDMoney is MintableToken {
  string public name = "IDMONEY";
  string public symbol = "IDM";
  uint256 public decimals = 18;
}