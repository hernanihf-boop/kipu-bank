//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title KipuBank
 * @author Hernán Iannello
 * @notice Contrato inteligente que permite a los usuarios depositar ETH
 * en una bóveda personal y retirarlos con un límite por transacción.
 */
contract KipuBank {
    // ====================================================================
    // VARIABLES INMUTABLES, DE ESTADO Y ALMACENAMIENTO (STORAGE)
    // ====================================================================

    // --- VARIABLES INMUTABLES (IMMUTABLE) ---

    /**
     * @dev Dirección del dueño del contrato. Se fija en el despliegue.
     */
    address public immutable owner;

    /**
     * @dev Límite máximo de ETH que se puede retirar en una sola transacción.
     */
    uint256 public immutable MAX_WITHDRAWAL = 0.5 ether;

    /**
     * @dev Capacidad total de ETH que el banco puede contener (en Wei).
     * @dev Fijo en el despliegue para asegurar la capacidad.
     */
    uint256 private immutable bankCap;

    // --- VARIABLES DE ESTADO (STORAGE) ---

    /**
     * @dev Mapeo que guarda el saldo personal de ETH de cada usuario (en Wei).
     * @dev La clave es la dirección del usuario.
     */
    mapping(address => uint256) private balances;

    /**
     * @dev Contador de la cantidad total de depósitos exitosos realizados.
     */
    uint256 private totalDeposits;

    /**
     * @dev Contador de la cantidad total de retiros exitosos realizados.
     */
    uint256 private totalWithdrawals;

    // ====================================================================
    // EVENTOS
    // ====================================================================

    /**
     * @dev Emitido cuando un usuario deposita ETH exitosamente.
     * @param user Dirección que depositó.
     * @param amount Cantidad depositada (en Wei).
     * @param newBalance Nuevo saldo del usuario.
     */
    event DepositSuccessful(address indexed user, uint256 amount, uint256 newBalance);

    /**
     * @dev Emitido cuando un usuario retira ETH exitosamente.
     * @param user Dirección que retiró.
     * @param amount Cantidad retirada (en Wei).
     * @param newBalance Nuevo saldo del usuario.
     */
    event WithdrawalSuccessful(address indexed user, uint256 amount, uint256 newBalance);

    // ====================================================================
    // ERRORES PERSONALIZADOS (CUSTOM ERRORS)
    // ====================================================================

    /**
     * @dev Emitido cuando un depósito falla porque la cantidad enviada es cero.
     */
    error ZeroDeposit();

    /**
     * @dev Emitido cuando el depósito excede el límite total del banco (bankCap).
     */
    error BankCapExceeded();

    /**
     * @dev Emitido cuando el usuario intenta retirar más de lo que tiene en su bóveda.
     * @param requested Solicitado.
     * @param available Total disponible en la bóveda.
     */
    error InsufficientFunds(uint256 available, uint256 requested);

    /**
     * @dev Emitido cuando un retiro excede el límite máximo por transacción (MAX_RETIRO).
     * @param limit Maximo permitido por retiro.
     * @param requested Cantidad que el usuario intenta retirar.
     */
    error WithdrawalLimitExceeded(uint256 limit, uint256 requested);

    /**
     * @dev Emitido si la transferencia de ETH nativo al usuario falla.
     */
    error TransferFailed();

    /**
     * @dev Emitido cuando una llamada a una función no es realizada por el owner de la dirección.
     * @param caller El llamador a la función.
     * @param owner El owner de la dirección.
     */
    error UnauthorizedCaller(address caller, address owner);

    // ====================================================================
    // CONSTRUCTOR Y MODIFICADORES
    // ====================================================================

    /**
     * @dev Modificador para validar que solo el dueño pueda llamar a la función.
     */
    modifier onlyOwner() {
      if (msg.sender != owner) revert UnauthorizedCaller(msg.sender, owner);
      _;
   }

    /**
     * @dev Constructor que inicializa el contrato.
     * @param _bankCap El límite total de depósitos que el contrato puede aceptar (en ETH).
     * @notice Establece el dueño del contrato y el límite global de depósitos.
     */
    constructor(uint256 _bankCap) {
        owner = msg.sender;
        bankCap = _bankCap * 1 ether; // Convierte el input (en ETH) a Wei
    }

    // ====================================================================
    // FALLBACK / RECEIVE 
    // ====================================================================

    /**
     * @dev La función 'receive' se ejecuta cuando alguien envía ETH al contrato
     * sin especificar una función a llamar.
     * En este caso, simplemente llama a la función 'deposit'.
     * @notice Permite depositar ETH de forma simple sin especificar la función 'deposit'.
     */
    receive() external payable {
        deposit();
    }

    // ====================================================================
    // FUNCIONES PÚBLICAS Y EXTERNAS (INTERACCIONES)
    // ====================================================================

    /**
     * @notice Permite al usuario retirar ETH de su bóveda personal.
     * @param _amount Cantidad de ETH (en Wei) que el usuario desea retirar.
     */
    function withdraw(uint256 _amount) external {
        address user = msg.sender;
        if (_amount > balances[user]) {
            revert InsufficientFunds(balances[user], _amount);
        }

        if (_amount > MAX_WITHDRAWAL) {
            revert WithdrawalLimitExceeded(MAX_WITHDRAWAL, _amount);
        }

        balances[user] -= _amount;
        totalWithdrawals++;

        (bool success, ) = payable(user).call{value: _amount}("");
        if (!success) {
            balances[user] += _amount;
            revert TransferFailed();
        }
        emit WithdrawalSuccessful(user, _amount, balances[user]);
    }

    /**
     * @notice Permite a cualquier usuario depositar ETH en su bóveda personal.
     */
    function deposit() public payable {
        uint256 amount = msg.value;
        address user = msg.sender;

        if (amount == 0) {
            revert ZeroDeposit();
        }

        if (address(this).balance > bankCap) {
            revert BankCapExceeded();
        }

        balances[user] += amount;
        totalDeposits++;
        emit DepositSuccessful(user, amount, balances[user]);
    }

    // ====================================================================
    // FUNCIONES DE VISTA (VIEW) Y PRIVADAS
    // ====================================================================

    /**
     * @notice Devuelve el saldo de ETH del usuario que llama a la función (en Wei).
     * @return El saldo del usuario.
     */
    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    /**
     * @notice Devuelve la cantidad total de depósitos que se han realizado.
     * @return El contador total de depósitos.
     */
    function getTotalDeposits() public view returns (uint256) {
        return totalDeposits;
    }

    /**
     * @notice Devuelve la cantidad total de retiros que se han realizado.
     * @return El contador total de retiros.
     */
    function getTotalWithdrawals() public view returns (uint256) {
        return totalWithdrawals;
    }

    /**
     * @notice Devuelve la capacidad máxima total de ETH que el banco puede contener.
     * @return El bankCap del contrato (en Wei).
     */
    function getBankCap() public view returns (uint256) {
        return bankCap;
    }

    /**
     * @dev Función privada que devuelve el saldo actual de un usuario.
     * @return El saldo de ETH del usuario (en Wei).
     */
    function _getUserBalance(address _user) private view returns (uint256) {
        return balances[_user];
    }
}