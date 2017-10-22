pragma solidity ^0.4.11;
/**
 * @title IDMoney
 * @dev Mintable ERC20 Token 
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 * Moneda base de IDPay para moneda aprobada por ID paises.
 */

/** 
Etapas: 
NotICO : No se aceptan inversiones
ICO : Se aceptan inversiones
*/

import './token/StandardToken.sol';

contract IDMoney is StandardToken {
  using SafeMath for uint256;

  string public name = "IDMONEY";
  string public symbol = "IDM";
  uint256 public decimals = 18; 
  uint256 public unit1 = 1;

  // Se define la minima inversion definida
  uint256 public constant ETH_RECEIVED_MIN = 1; // Minima cantidad de ETH a recibir como inversion

  // Fundraising parameters
  enum ContractState { ICO, NotICO }
  uint256 public tokenETHExchange = 0;  // No tenemos tipo de cambio
  ContractState public state;           // Estado del contrato y token
  uint256 public cap;                   // Maximo del ICO actual

  // Variables de Control
  uint256 public ethReceived;           // ETH Recibidos en el ICO
  address[] public ethInvestors;        // Control que se lleva de inversionistas 
  

  // Direcciones para depositar los ETH. Definirlas o hacer una func para asignarlas
  address public ethFundIandD;     /** Cuenta para I&D */
  address public ethFundFounders;  /** Cuenta para Fundadores */
  address public ethFundEscrow;    /** Cuenta para Fideicomiso Escrow */
  address public ethFundMain;      /** Cuenta / Resto */

  address public owner;
  
  /**
   * @dev Al contruir la moneda se guardar la direccion del owner
   */
  function IDMoney() public {
    // owner es el creador
    owner = msg.sender;
    // Entramos en estado NotICO
    state = ContractState.NotICO;
  }

  /**
   * @dev Modificador que chequea si la funcion la esta ejecutando el owner
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier isICO() {
    require(state == ContractState.ICO);
    _;
  }

  modifier isNotICO() {
    require(state == ContractState.NotICO);
    _;
  }

  /**
   * @dev Permite al owner actual transferir el control a otro owner
   *      Solo se puede pasar si no esta recibiendo fontos y es el owner
   * @param newOwner La direccion a la cual se transfiere el control.
   */
  function transferOwnership(address newOwner) onlyOwner isNotICO public {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

  /**
   * @dev Permite al owner actual ponerse en estado ICO
   *      Solo se puede pasar si todavia esta en estado PreICO
   */
   // Cambiar y poner de parametro el tipo de cambio....
   // Manejar el cap e inicializar el vector de inversionistas...
  function beginICO(uint256 ethexchange, uint256 capICO) onlyOwner isNotICO public {
    // El tipo de cambio debe ser mayor a 1
    require(ethexchange > 1);
    require(capICO > 0);
    // Entrar en estado ICO
    state = ContractState.ICO;
    // Asignar el cap del ICO definido
    cap = capICO;
    // Asignar el tipo de cambio
    tokenETHExchange = ethexchange;
    // Reset a los ETH recibidos
    ethReceived = 0;
    // Crear el vector de inversionistas
    ICOstarted(ethexchange, capICO);
  }

  /**
   * @dev Permite al owner actual ponerse en estado sin funding
   *      Solo se puede pasar si todavia esta en estado ICO
   */
  function endICO() onlyOwner isICO public {
    // Entrar en estado NotICO
    state = ContractState.NotICO;
    tokenETHExchange = 0;
    cap = 0;
    ethReceived = 0;
    // Borrar el vector de inversionistas (devolverlo ?)
    ICOended();
  }

  event ICOstarted(uint256 ethexchange, uint256 capICO);
  event ICOended();

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
  function doMint(address _to, uint256 _amount) private returns (bool) {
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
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(_amount >= 1);  // El monto a generar debe ser mayor o igual a 1
    doMint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  /**
   * @dev Funcion que graba la direccion de un inversionista en el vector.
   * @return El precio del token IDM por cada 1 ETH
   */
  function addICOInvestor(address _to) public returns (bool) {
    // Agregue la direccion en el vector de inversionistas
    ethInvestors.push(_to);    
    return true;
  }

  /**
   * @dev Funcion que devuelve el precio de los IDM de acuerdo a la etapa del ICO.
   * @return El precio del token IDM por cada 1 ETH
   */
  function getCurrentTokenPrice() private view returns (uint256 currentPrice) {
    return tokenETHExchange;
  }

  /// 
  /// requires { arg_data.length < UInt256.max_uint256 }
  /// requires { 0 <= to_int arg_begin <= to_int arg_end <= arg_data.length }
  /// requires { forall i j: int. 0 <= i <= j < arg_data.length -> to_int arg_data[i] <= to_int arg_data[j] }
  /// variant { to_int arg_end - to_int arg_begin }
  /// ensures {
  ///   to_int result < UInt256.max_uint256 -> (to_int arg_begin <= to_int result < to_int arg_end && to_int arg_data[to_int result] = to_int arg_value)
  /// }
  /// ensures {
  ///   to_int result = UInt256.max_uint256 -> (forall i: int. to_int arg_begin <= i < to_int arg_end -> to_int arg_data[i] <> to_int arg_value)
  /// }
  function findinternal(uint[] data, uint begin, uint end, uint value) internal returns (uint ret) {
    uint len = end - begin;
    if (len == 0 || (len == 1 && data[begin] != value)) {
      return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }
    uint mid = begin + len / 2;
    uint v = data[mid];
    if (value < v)
      return findinternal(data, begin, mid, value);
    else if (value > v)
      return findinternal(data, mid + 1, end, value);
    else
      return mid;
  }

  ///
  /// requires { arg_data.length < UInt256.max_uint256 }
  /// requires { forall i j: int. 0 <= i <= j < arg_data.length -> to_int arg_data[i] <= to_int arg_data[j] }
  /// ensures {
  ///   to_int result < UInt256.max_uint256 -> to_int arg_data[to_int result] = to_int arg_value
  /// }
  /// ensures {
  ///   to_int result = UInt256.max_uint256 -> forall i: int. 0 <= i < arg_data.length -> to_int arg_data[i] <> to_int arg_value
  /// }
  function find(uint[] data, uint value) internal returns (uint ret) {
    return findinternal(data, 0, data.length, value);
  }


  /**
   * @dev Funcion que revive ETH directamente pero solamente si esta en el estado correcto.
   * @return True si la operacion fue correcta.
   */
  function () isICO payable public {
    require(msg.value > 0);  // El monto de ETH debe ser mayor que 0
    require(msg.value > ETH_RECEIVED_MIN);  // El monto de ETH debe ser mayor que el minimo definido
    require(tokenETHExchange > 1); // Tiene que haber tipo de cambio y debe ser mayor que uno.
    require(cap > 0); // Tiene que haber un cap y debe ser mayor a 0.
    require(ethReceived + msg.value <= cap); // Revisar que no sobrepase el cap.

    // aca hay que tomar los eth (msg.value) y distribuirlos. address.send(msg.value)
    uint256 tokreceive = getCurrentTokenPrice() * msg.value; // Calcula el total de tokens a generar
    doMint(owner,tokreceive); // Agrega tokens a billetera de dueno.
    transferFrom(owner, msg.sender, tokreceive); // Envia tokens desde el dueno al inversor.
    ethReceived = ethReceived + msg.value;  // Sumar los ETH en la variable de control
  }

}