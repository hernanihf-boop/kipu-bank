# 🏦 KipuBank 
Contrato de Bóveda de ETH con Límite de Retiro


#### 📝 Descripción del Proyecto
El KipuBank es un contrato inteligente escrito en Solidity (versión >=0.7.0 <0.9.0) que funciona como una bóveda descentralizada de Ether (ETH) para sus usuarios.
Este contrato fue diseñado como un ejercicio para aplicar buenas prácticas de seguridad y optimización de gas en el ecosistema Ethereum.


#### ✅ Características Clave:
* Los usuarios pueden enviar ETH al contrato y este se registra en su saldo personal.
* Límite Inmutable de Retiro (MAX_WITHDRAWAL): El contrato aplica un límite fijo de 0.5 ETH por transacción de retiro, definido con el keyword immutable para garantizar que la regla de seguridad nunca pueda ser alterada.
* Capacidad Máxima (bankCap): Se establece un límite global de depósitos al momento del despliegue para controlar la exposición total del banco.
* Optimización con errores personalizados: Se usan custom errors en lugar de require strings para ahorrar gas en las transacciones que revierten.


#### 🚀 Instrucciones de Despliegue
Para desplegar el contrato KipuBank, necesitarás un entorno de desarrollo de Solidity (como Remix IDE).
Requisito de Despliegue (Parámetro del Constructor)
Al ser un contrato con constructor, debés pasar un único parámetro al momento de desplegar: bankCap (uint256)
La capacidad máxima de depósitos del banco, expresada en ETH. Si ponés 100, el límite total es de 100 ETH.


###### 👣 Pasos Generales (Usando Remix IDE)


###### ⚙️ Compilación: 
Abrí KipuBank.sol en Remix, asegurate de que el compilador cumpla con versión >=0.7.0 <0.9.0, y compilá el contrato.


###### 🛫 Despliegue: 
Andá a la pestaña de "Deploy & Run Transactions".
Seleccioná un entorno (por ejemplo, Injected Provider para usar MetaMask en una testnet como Sepolia).
En el campo bankCap, ingresá el valor deseado (e.g., 500). Hacé clic en Deploy.
Transacción: Confirmá la transacción en MetaMask. Una vez minado el bloque, tu contrato estará en vivo. 


###### 🕹️ Cómo Interactuar con KipuBank:

Una vez desplegado, podés interactuar con el contrato a través de las siguientes funciones:

1. Depositando ETH (deposit)

Esta función es payable y te permite enviar ETH a tu bóveda personal.

Método: deposit()

Uso: Hacé una transacción al contrato, asegurándote de adjuntar la cantidad de ETH que querés depositar en el campo Value.

Ejemplo: Para depositar , enviá la transacción a deposit() con Value = 0.2 ETH.

2. Retirando Fondos (withdraw)

Esta función te permite sacar ETH de tu saldo personal, respetando el límite por transacción.

Método: withdraw(uint256 _amount)

Parámetro: _amount debe ser la cantidad que querés retirar, expresada en Wei.

Límite: Recordá que _amount no puede ser mayor que el límite inmutable (MAX_WITHDRAWAL, fijado en ).

Ejemplo: Para retirar  (que son ), llamá a withdraw(500000000000000000).

3. Consultando el Saldo (getMyBalance)

Función de lectura gratuita que devuelve tu saldo personal.

Método: getMyBalance()

Devuelve: Tu saldo total en la bóveda, expresado en Wei.

4. Consultando el Límite (MAX_WITHDRAWAL y getBankCap)

Podés leer los límites fijos del contrato.

Método: MAX_WITHDRAWAL (variable pública, lectura directa).

Método: getBankCap() (devuelve el límite global del banco en Wei).


### ABI contract

```
[
  {
    "type": "constructor",
    "inputs": [
      {
        "name": "_bankCap",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "name": "BankCapExceeded",
    "type": "error",
    "inputs": []
  },
  {
    "name": "InsufficientFunds",
    "type": "error",
    "inputs": [
      {
        "name": "available",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "requested",
        "type": "uint256",
        "internalType": "uint256"
      }
    ]
  },
  {
    "name": "TransferFailed",
    "type": "error",
    "inputs": []
  },
  {
    "name": "UnauthorizedCaller",
    "type": "error",
    "inputs": [
      {
        "name": "caller",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "owner",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  {
    "name": "WithdrawalLimitExceeded",
    "type": "error",
    "inputs": [
      {
        "name": "limit",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "requested",
        "type": "uint256",
        "internalType": "uint256"
      }
    ]
  },
  {
    "name": "ZeroDeposit",
    "type": "error",
    "inputs": []
  },
  {
    "name": "DepositSuccessful",
    "type": "event",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "newBalance",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "name": "WithdrawalSuccessful",
    "type": "event",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "newBalance",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "name": "MAX_WITHDRAWAL",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "name": "deposit",
    "type": "function",
    "inputs": [],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "name": "getBankCap",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "name": "getMyBalance",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "name": "getTotalDeposits",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "name": "getTotalWithdrawals",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "name": "owner",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "view"
  },
  {
    "name": "withdraw",
    "type": "function",
    "inputs": [
      {
        "name": "_amount",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "receive",
    "stateMutability": "payable"
  }
]
```