pragma solidity ^0.4.18;
/**
 * @title IDMoney
 * @dev Mintable ERC20 Token 
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 * IDPAY (id based crypto currency).
 */

/** 
Stages: 
NotICO : ICO not active
ICO : ICO active
*/

import './token/StandardToken.sol';

contract IDMoney is StandardToken {
  using SafeMath for uint256;

  // public variables for ERC20 standard
  string public name = "IDMONEY";
  string public symbol = "IDM";
  uint256 public decimals = 18; 
  uint256 public unit1 = 1;

  // Min ETH amount to invest
  uint256 public constant ETH_RECEIVED_MIN = 1; 

  // ICO handling parameters
  enum ContractState { ICO, NotICO }
  uint256 public tokenETHExchange = 0;  // default: exchange is zero.
  ContractState public state;           // State of the contract
  uint256 public cap;                   // cap of ICO if in ICO State

  // Variables para guardar datos de ICO
  uint256 public ethReceived;           // ETH received in ICO
  address[] private ethInvestors;       // Inversors List 
  uint256[] private ethInvestorstotal;  // Investment List
  
  // Addresses for ETH deposit. 
  // Still not to be used.
  address public ethFundIandD;     /** I&D Wallet */
  address public ethFundFounders;  /** Founders Wallet */
  address public ethFundEscrow;    /** Fund Escrow Wallet */
  address public ethFundMain;      /** Account / The rest */

  address public owner;
  
  /**
   * @dev When creating the currency the owner address is saved from the deployment address
   */
  function IDMoney() public {
    // owner is the creator
    owner = msg.sender;
    // Entering NotICO state
    state = ContractState.NotICO;
  }

  /**
   * @dev Modifier that checks if the function is being executed by the owner
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Modifier that checks if we are in ICO state
   */
  modifier isICO() {
    require(state == ContractState.ICO);
    _;
  }

  /**
   * @dev Modifier that checks if we are in NotICO state
   */
  modifier isNotICO() {
    require(state == ContractState.NotICO);
    _;
  }

  /**
   * @dev Allows the current owner to transfer ownership to a different address
   *      It can only be executed when the owner is doing it and we are in NotICO state
   * @param newOwner Address which receives the ownership.
   */
  function transferOwnership(address newOwner) onlyOwner isNotICO public {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
 
  /* ICO Events */
  event ICOstarted(uint256 ethexchange, uint256 capICO);
  event ICOended();

  /**
   * @dev Put the contract in the ICO state
   *      It can only be executed if the contract is in NotICO state
   *      It can only be executed by the owner
   * @param ethexchange exchage rate ETH>IDC for this ICO. Ex:100 means 100 IDM for 1 ETH
   * @param capICO max amount of ETH to be accepted in this ICO.
   */
  function beginICO(uint256 ethexchange, uint256 capICO) onlyOwner isNotICO public {
    // Exchange rate must be more than 1
    require(ethexchange > 1);
    require(capICO > 0);
    // Change contract state to ICO
    state = ContractState.ICO;
    // Asign cap amount to this ICO
    cap = capICO;
    // Asign exchange rate
    tokenETHExchange = ethexchange;
    // Reset ETH received
    ethReceived = 0;
    // Clear investments and investors arrays
    ethInvestors = new address[](0);
    ethInvestorstotal = new uint[](0);
    // Generate ICOstarted event
    ICOstarted(ethexchange, capICO);
  }

  /**
   * @dev End the ICO
   *      It can only be executed if the contract is in ICO state
   *      It can only be executed by the owner
   */
  function endICO() onlyOwner isICO public {
    // Change contract state to NotICO
    state = ContractState.NotICO;
    // Asign 0 to exchange rate and cap amount.
    tokenETHExchange = 0;
    cap = 0;
    // Investments and investor arrays are not cleared (so we can check them)
    // Generate ICOended event
    ICOended();
  }

  /**
   * @dev Returns investors array
   *      It can only be executed by the owner
   */
  function getInvestorsAddresses() public constant onlyOwner returns (address[] data) {
      return (ethInvestors);
  }

  /**
   * @dev Returns investments array
   *      It can only be executed by the owner
   */
  function getInvestorsTotal() public constant onlyOwner returns (uint256[] data) {
      return (ethInvestorstotal);
  }

  /** Minting Events
  */
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  // Minting ending control to avoid the generation of new currency when minting
  bool public mintingFinished = false;

  /** Investment related event
  */
  event AddInvestor(address indexed investor, uint256 amount);
  
   /**
   * @dev Modifier that checks if we can Mint new currency
   */
  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Functions that does token minting for the ICO (private)
   * @param _to Address that receives the generated tokens
   * @param _amount Token amount to generate.
   * @return Boolean signals if operation was successful.
   */
  function doMint(address _to, uint256 _amount) private returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Functions that creates new tokens
   *      It can only be executed if is not minting
   *      It can only be executed by the owner
   * @param _to Address that receives the generated tokens.
   * @param _amount Token amount to generate.
   * @return Boolean signals if operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(_amount >= 1);  // Amount must be more of equal than 1
    doMint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   *      It can only be executed by the owner
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  /**
   * @dev Function that saves an investor address in an array.
   *      If the investor is already there it adds the corresponding amount
   *      It can only be executed by the owner
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