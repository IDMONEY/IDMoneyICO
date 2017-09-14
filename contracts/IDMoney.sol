pragma solidity ^0.4.11;
/**
 * @title IDMoney
 * @dev Mintable ERC20 Token 
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 * Moneda base de IDPay para moneda aprobada por ID paises.
 */

import './token/StandardToken.sol';

contract IDMoney is StandardToken {
  string public name = "IDMONEY";
  string public symbol = "IDM";
  uint256 public decimals = 18; 

  address public owner;

  /**
   * @dev Al contruir la moneda se guardar la direccion del owner
   */
  function IDMoney() {
    owner = msg.sender;
  }

  /**
   * @dev Modificador que chequea si la funcion la esta ejecutando el owner
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Permite al owner actual transferir el control a otro owner
   * @param newOwner La direccion a la cual se transfiere el control.
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

  /** Eventos relacionados con la creacion de moneda IDM adicional */
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;
  
  /** Modificador que especifica si se puede crear nueva moneda */
  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Funcion para crear nuevos tokens
   * @param _to La direccion que recibira nuevos tokens.
   * @param _amount La cantidad de tokens a generar.
   * @return Boolean que indica si la operacion fue exitosa.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

}