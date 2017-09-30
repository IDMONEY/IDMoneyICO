pragma solidity ^0.4.11;
/**
 * @title IDMoney
 * @dev Mintable ERC20 Token 
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 * Moneda base de IDPay para moneda aprobada por ID paises.
 */

/** 
Etapas: 
Larvae : Inversores VIP, el tipo de cambio se acepta en forma manual como deposito en ETH en cuenta de owner.
         El owner se encargara de enviar el IDM 
Pre-ICO : Se aceptan directamente al contrato con un 70% de descuento
Durante ICO : Aqui el acceso es abierto, NO hay descuento
Post-ICO : No se aceptan contribuciones, solamente puede haber Minting. Es probable cerrar minting para siempre.
*/

import './token/StandardToken.sol';

contract IDMoney is StandardToken {
  string public name = "IDMONEY";
  string public symbol = "IDM";
  uint256 public decimals = 18; 
  uint256 public unit1 = 1;

  // Se define el tipo de cambio preICO y el que tendremos durante el ICO
  uint256 public constant TOKEN_EXCHANGE_RATE_PREICO = 7000; // 7000 IDMs per 1 ETH, 30% Descuento
  uint256 public constant TOKEN_EXCHANGE_RATE_ICO = 10000; // 10000 IDMs per 1 ETH
  uint256 public constant ETH_RECEIVED_MIN = 1; // Minima cantidad de ETH a recibir como inversion

  // Fundraising parameters
  enum ContractState { Larvae, PreICO, ICO, PostICO }
  ContractState public state;           // Estado del contrato y token

  // Direcciones para depositar los ETH. Definirlas o hacer una func para asignarlas
  address public ethFundIandD;     /** Cuenta para I&D */
  address public ethFundFounders;  /** Cuenta para Fundadores */
  address public ethFundEscrow;    /** Cuenta para Fideicomiso Escrow */
  address public ethFundMain;      /** Cuenta / Resto */

  address public owner;
  
  /**
   * @dev Al contruir la moneda se guardar la direccion del owner
   */
  function IDMoney() {
    // owner es el creador
    owner = msg.sender;
    // Entramos en estado Larva (VIP antes de PreICO)
    state = ContractState.Larvae;
  }

  /**
   * @dev Modificador que chequea si la funcion la esta ejecutando el owner
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier isLarvae() {
      require(state == ContractState.Larvae);
      _;
  }

  modifier isPreICO() {
      require(state == ContractState.PreICO);
      _;
  }

  modifier isICO() {
      require(state == ContractState.ICO);
      _;
  }

  modifier isPostICO() {
      require(state == ContractState.PostICO);
      _;
  }

  modifier isFundraising() {
      require(state == ContractState.PreICO || state == ContractState.ICO);
      _;
  }

  /**
   * @dev Permite al owner actual transferir el control a otro owner
   *      Solo se puede pasar si todavia esta en estado Larvae
   * @param newOwner La direccion a la cual se transfiere el control.
   */
  function transferOwnership(address newOwner) onlyOwner isLarvae {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

  /**
   * @dev Permite al owner actual ponerse en estado PreICO
   *      Solo se puede pasar si todavia esta en estado Larvae
   */
  function beginPreICO() onlyOwner isLarvae {
    // Entrar en estado PreICO
    state = ContractState.PreICO;
  }

  /**
   * @dev Permite al owner actual ponerse en estado ICO
   *      Solo se puede pasar si todavia esta en estado PreICO
   */
  function beginICO() onlyOwner isPreICO {
    // Entrar en estado ICO
    state = ContractState.ICO;
  }

  /**
   * @dev Permite al owner actual ponerse en estado PostICO
   *      Solo se puede pasar si todavia esta en estado ICO
   */
  function endICO() onlyOwner isICO {
    // Entrar en estado PostICO
    state = ContractState.PostICO;
  }

  /** Eventos relacionados con la creacion de moneda IDM adicional 
  */
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;
  
  /** Modificador que especifica si se puede crear nueva moneda 
  */
  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Funcion para efectua minting de tokens para Minting y para el ICO
   * @param _to La direccion que recibira nuevos tokens.
   * @param _amount La cantidad de tokens a generar.
   * @return Boolean que indica si la operacion fue exitosa.
   */
  function doMint(address _to, uint256 _amount) 
  private
  returns (bool)
  {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Funcion para crear nuevos tokens
   * @param _to La direccion que recibira nuevos tokens.
   * @param _amount La cantidad de tokens a generar.
   * @return Boolean que indica si la operacion fue exitosa.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    require(_amount >= 1);  // El monto a generar debe ser mayor o igual a 1
    doMint(_to, _amount);
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

  /**
   * @dev Funcion que devuelve el precio de los IDM de acuerdo a la etapa del ICO.
   * @return El precio del token IDM por cada 1 ETH
   */
  function getCurrentTokenPrice() 
    private
    constant
    returns (uint256 currentPrice) 
  {
    if (state == ContractState.PreICO) {
        return TOKEN_EXCHANGE_RATE_PREICO;
    } else {
        return TOKEN_EXCHANGE_RATE_ICO;
    }
  }

  /**
   * @dev Funcion que revive ETH directamente pero solamente si esta en el estado correcto.
   * @return True si la operacion fue correcta.
   */
  function () isFundraising payable {
    require(msg.value > 0);  // El monto de ETH debe ser mayor que 0
    require(msg.value > ETH_RECEIVED_MIN);  // El monto de ETH debe ser mayor que el minimo definido

    // aca hay que tomar los eth (msg.value) y distribuirlos.
    uint256 tokreceive = getCurrentTokenPrice() * msg.value; // Calcula el total de tokens a generar
    doMint(owner,tokreceive); // Agrega tokens a billetera de dueno.
    transferFrom(owner, msg.sender, tokreceive); // Envia tokens desde el dueno al inversor.
  }

}