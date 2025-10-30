# Bank Smart Contract

A simple yet secure banking system built on Ethereum that allows users to create accounts, deposit, withdraw, and transfer funds between accounts.

## Features

- **Account Creation**: Users can create their own bank accounts with a custom name
- **Deposits**: Anyone can deposit ETH to any existing account
- **Withdrawals**: Account owners can withdraw their balance
- **Transfers**: Transfer funds between accounts instantly
- **Access Control**: Only account owners can manage their accounts
- **Event Logging**: All operations emit events for transparency

## Smart Contract Overview

### Account Structure
Each account contains:
- `owner`: The Ethereum address that owns the account
- `name`: A custom name for the account
- `balance`: The ETH balance stored in the account
- `exists`: Boolean flag indicating if the account exists

### Core Functions

#### `createAccount(string memory _name)`
Creates a new bank account for the caller.
- **Access**: Public
- **Requirements**: Account must not already exist
- **Emits**: `AccountCreated` event

#### `deposit(address to)`
Deposits ETH into a specified account.
- **Access**: Public (anyone can deposit to any account)
- **Requirements**: 
  - Recipient account must exist
  - Must send ETH with the transaction
- **Emits**: `DepositMade` event

#### `withdraw(uint256 amount)`
Withdraws ETH from the caller's account.
- **Access**: Account owner only
- **Requirements**: Sufficient balance
- **Security**: Uses Checks-Effects-Interactions pattern
- **Emits**: `WithdrawalMade` event

#### `transferTo(address to, uint256 amount)`
Transfers funds from caller's account to another account.
- **Access**: Account owner only
- **Requirements**: 
  - Recipient account must exist
  - Sufficient balance
- **Emits**: `TransferMade` event

#### `viewBalance()`
Returns the caller's account balance.
- **Access**: Account owner only
- **Returns**: `uint256` balance

#### `getAccountDetails(address owner)`
Returns account details for the specified address.
- **Access**: Account owner only (can only view own account)
- **Returns**: `(address owner, string name, uint256 balance, bool exists)`

## Security Features

### Reentrancy Protection
The contract implements the **Checks-Effects-Interactions (CEI)** pattern in the `withdraw` function:
1. **Checks**: Verify sufficient balance
2. **Effects**: Update state (deduct balance)
3. **Interactions**: Send ETH using `call`

### Modern ETH Transfer
Uses `call` instead of `transfer` or `send`:
- Forwards all available gas
- Compatible with smart contract wallets
- More future-proof
- Properly handles success/failure

### Access Control
- Custom modifiers ensure only account owners can access their accounts
- Prevents unauthorized withdrawals and transfers

## Events

```solidity
event AccountCreated(address indexed owner, string name);
event DepositMade(address indexed depositor, address indexed to, uint256 amount);
event WithdrawalMade(address indexed owner, uint256 amount);
event TransferMade(address indexed sender, address indexed receiver, uint256 amount);
```

## Installation & Setup

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Solidity ^0.8.30

### Install Dependencies
```bash
forge install
```

### Compile
```bash
forge build
```

### Run Tests
```bash
forge test
```

### Run Tests with Verbosity
```bash
forge test -vvv
```

### Test Coverage
```bash
forge coverage
```

## Usage Example

### Creating an Account
```solidity
bank.createAccount("Alice");
```

### Depositing Funds
```solidity
bank.deposit{value: 1 ether}(aliceAddress);
```

### Withdrawing Funds
```solidity
bank.withdraw(0.5 ether);
```

### Transferring Between Accounts
```solidity
bank.transferTo(bobAddress, 0.3 ether);
```

### Checking Balance
```solidity
uint256 balance = bank.viewBalance();
```

## Testing

The project includes comprehensive tests covering:
- ✅ Account creation (success and failure cases)
- ✅ Deposits (including edge cases)
- ✅ Withdrawals (with access control)
- ✅ Transfers (between accounts)
- ✅ Balance viewing
- ✅ Access control verification
- ✅ Error handling

### Test Structure
```
test/
└── BankTest.t.sol    # Comprehensive test suite
```

### Running Specific Tests
```bash
forge test --match-test testCreateAccount
```

## Gas Optimization

The contract uses several gas-efficient patterns:
- Storage variables packed efficiently
- Single SLOAD operations where possible
- Events for off-chain data tracking
- Minimal external calls

## Known Limitations

1. **Single Account Per Address**: Each address can only create one account
2. **No Account Deletion**: Once created, accounts cannot be deleted
3. **Name Immutability**: Account names cannot be changed after creation
4. **Privacy**: Account details are only visible to the owner (except through events)

## Future Improvements

Potential enhancements:
- [ ] Multiple accounts per address
- [ ] Account name updates
- [ ] Interest calculation
- [ ] Transaction history tracking
- [ ] Account recovery mechanism
- [ ] Multi-signature support
- [ ] Upgradeable contract pattern

## License

MIT License - see [LICENSE](LICENSE) file for details

## Author

Built with ❤️ as a learning project for Solidity smart contract development

## Disclaimer

⚠️ **This contract is for educational purposes only.** It has not been audited and should not be used in production with real funds without a professional security audit.

## Resources

- [Solidity Documentation](https://docs.soliditylang.org/)
- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Smart Contract Security Best Practices](https://consensys.github.io/smart-contract-best-practices/)

---

**Questions or Issues?** Feel free to open an issue or submit a pull request!
