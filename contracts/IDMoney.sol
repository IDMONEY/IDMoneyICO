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

  // Variables publicas para estandar ERC20
  string public name = "IDMONEY";
  string public symbol = "IDM";
  uint256 public decimals = 18; 
  uint256 public unit1 = 1;

  // Se define la minima inversion definida
  uint256 public constant ETH_RECEIVED_MIN = 1; // Minima cantidad de ETH a recibir como inversion

  // Parametros para manejo de ICO
  enum ContractState { ICO, NotICO }
  uint256 public tokenETHExchange = 0;  // No tenemos tipo de cambio
  ContractState public state;           // Estado del contrato y token
  uint256 public cap;                   // Maximo del ICO actual

  // Variables para guardar datos de ICO
  uint256 public ethReceived;           // ETH Recibidos en el ICO
  address[] private ethInvestors;       // Lista de inversionistas 
  uint256[] private ethInvestorstotal;  // Lista de inversiones
  
  // Direcciones para depositar los ETH. Definirlas o hacer una func para asignarlas
  // Todavia no se usan
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

  /**
   * @dev Modificador que indica si estamos en un proceso de recepcion de fondos (ICO)
   */
  modifier isICO() {
    require(state == ContractState.ICO);
    _;
  }

  /**
   * @dev Modificador que indica si NO estamos en un proceso de recepcion de fondos (ICO)
   */
  modifier isNotICO() {
    require(state == ContractState.NotICO);
    _;
  }

  /**
   * @dev Permite al owner actual transferir el control a otro owner
   *      Solo se puede pasar si no esta recibiendo fontos y es el owner quien ejecuta la funcion
   * @param newOwner La direccion a la cual se transfiere el control.
   */
  function transferOwnership(address newOwner) onlyOwner isNotICO public {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

  event ICOstarted(uint256 ethexchange, uint256 capICO);
  event ICOended();

  /**
   * @dev Permite al owner actual ponerse en estado ICO
   *      Solo se puede pasar si todavia esta en estado PreICO
   * @param ethexchange tipo de cambio con ETH de IDM para ese ICO. Ej:100 significa 100 IDM por 1 ETH
   * @param capICO maxima cantidad de ETH que vamos a aceptar en este ICO.
   */
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
    // Limpiar vectores de inversionistas
    ethInvestors = new address[](0);       // Lista de inversionistas 
    ethInvestorstotal = new uint[](0);    // Lista de inversiones
    // Genera el evento de que iniciamos un ICO
    ICOstarted(ethexchange, capICO);
  }

  /**
   * @dev Permite al owner actual ponerse en estado sin funding
   *      Solo se puede pasar si todavia esta en estado ICO
   */
  function endICO() onlyOwner isICO public {
    // Entrar en estado NotICO
    state = ContractState.NotICO;
    // Se deja el tipo de cambio y el maximo de ETH a recibir en cero.
    tokenETHExchange = 0;
    cap = 0;
    // No borrar vector de inversionistas para poder revisar su contenido.
    // Genera el evento de que terminamos el ICO
    ICOended();
  }

  /**
   * @dev Devuelve el vector de inversionistas aprobados
   */
  function getInvestorsAddresses() public constant onlyOwner returns (address[] data) {
      return (ethInvestors);
  }

  /**
   * @dev Devuelve el vector de inversiones recibidas (informacion complementaria a inversionistas)
   */
  function getInvestorsTotal() public constant onlyOwner returns (uint256[] data) {
      return (ethInvestorstotal);
  }

  /** Eventos relacionados con la creacion de moneda IDM adicional 
  */
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  // Control de finalizacion de minting que evita generar moneda nueva si se esta en proceso de generacion
  bool public mintingFinished = false;

  /** Evento relacionado con una inversion
  */
  event AddInvestor(address indexed investor, uint256 amount);
  
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
   *      Lo agrega si no esta y si esta suma al monto ya existente
   * @param _to La direccion aprobada que recibira nuevos tokens.
   * @param _amount La cantidad de tokens a recibir.
   * @return true si pudo agregar al inversionista
   */
  function addICOInvestor(address _to, uint256 _amount) public returns (bool) {
    require(_amount >= 0);  // El monto a ingresar debe ser mayor o igual a cero.
    uint256 index;
    // Revisar si esta en el vector
    index = findaddress(ethInvestors, _to);
    if (index < 999999) {
      // Esta, entonces sume el monto y ya.
      ethInvestorstotal[index] = ethInvestorstotal[index].add(_amount); 
      return true;  
    } else {
      // No esta en la lista, no agregue
      return false;
    }
  }

  /**
   * @dev Funcion que devuelve el precio de los IDM de acuerdo a la etapa del ICO.
   * @return El precio del token IDM por cada 1 ETH
   */
  function getCurrentTokenPrice() private view returns (uint256 currentPrice) {
    return tokenETHExchange;
  }

  /**
   * @dev Funcion de busqueda binaria de una direcion.
   * @param data Vector de direcciones.
   * @param begin Indice de inicio de la busqueda.
   * @param end Indice de finalizacion de la busqueda.
   * @param value valor a buscar (direccion).
   * @return Indice donde esta la direccion
   */
  function findinternal(address[] data, uint begin, uint end, address value) internal returns (uint ret) {
    uint len = end - begin;
    if (len == 0 || (len == 1 && data[begin] != value)) {
      return 999999;
    }
    uint mid = begin + len / 2;
    address v = data[mid];
    if (value < v)
      return findinternal(data, begin, mid, value);
    else if (value > v)
      return findinternal(data, mid + 1, end, value);
    else
      return mid;
  }

  /**
   * @dev Funcion que usa busqueda binaria y devuelve indice
   * @param data Vector de direcciones.
   * @param value Valor a buscar.
   * @return Indice donde esta la direccion
   */
  function findaddress(address[] data, address value) internal returns (uint ret) {
    return findinternal(data, 0, data.length, value);
  }


  /**
   * @dev Funcion que revive ETH directamente pero solamente si esta en el estado correcto.
          Chequea si el valor a depositar es mayor que 0.
          Chequea si el monto a depositar de ETH es mayor que el minimo definido
          Chequea si de cambio definido es mayor a 1
          Chequea que el cap (monto mayor a recibir acumulado) sea mayor que 0
          Chequea que el valor a pagar en esta operacion mas lo recibido no sea mayor que el cap
          Chequea el inversionista esta en la lista de inversionistas permitidos
   * @return True si la operacion fue correcta.
   */
  function () isICO payable public {
    require(msg.value > 0);  // El monto de ETH debe ser mayor que 0
    require(msg.value > ETH_RECEIVED_MIN);  // El monto de ETH debe ser mayor que el minimo definido
    require(tokenETHExchange > 1); // Tiene que haber tipo de cambio y debe ser mayor que uno.
    require(cap > 0); // Tiene que haber un cap y debe ser mayor a 0.
    require(ethReceived + msg.value <= cap); // Revisar que no sobrepase el cap.
    uint256 index;
    // Revisar si esta en el vector
    index = findaddress(ethInvestors, msg.sender);
    // El inversionista debe esta en la lista
    require(index < 999999);
    // aca hay que tomar los eth (msg.value) y distribuirlos. address.send(msg.value)
    // En esta version no se estan distribuyendo para ningun lugar
    uint256 tokreceive = getCurrentTokenPrice().mul(msg.value); // Calcula el total de tokens a generar
    doMint(owner,tokreceive); // Agrega tokens a billetera de dueno.
    transferFrom(owner, msg.sender, tokreceive); // Envia tokens desde el dueno al inversor.
    ethReceived = ethReceived.add(msg.value);  // Sumar los ETH en la variable de control
    addICOInvestor(msg.sender, msg.value);  // Agregarlo en el vector de inversionistas
    // Trigger del evento
    AddInvestor(msg.sender, msg.value);    
  }

}