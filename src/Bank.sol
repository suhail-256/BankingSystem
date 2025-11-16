// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Bank {
    // Define the Account struct

    using Strings for uint256;
    using Strings for address;

    struct Account {
        address owner;
        string name;
        uint256 balance;
        bool exists;
        string[] txHistory;
    }

    enum TxType {
        Deposit,
        Withdraw,
        Transfer
    }

    // Mapping to store accounts by owner address

    mapping(address => Account) private accounts;

    // events

    event AccountCreated(address indexed owner, string name);
    event DepositMade(address indexed depositor, address indexed to, uint256 amount);
    event WithdrawalMade(address indexed owner, uint256 amount);
    event TransferMade(address indexed sender, address indexed receiver, uint256 amount);

    // modifire to control account accses

    modifier onlyAccountOwner() {
        require(accounts[msg.sender].owner == msg.sender, "Not your account");
        _;
    }

    modifier accountdoesNotExists(address owner) {
        require(accounts[owner].exists, "Account does not exist");
        _;
    }

    // function to create account

    function createAccount(string memory _name) public {
        require(!accounts[msg.sender].exists, "Account already exists");

        accounts[msg.sender] =
            Account({owner: msg.sender, name: _name, balance: 0, exists: true, txHistory: new string[](0)});

        emit AccountCreated(msg.sender, _name);
    }

    // function to deposit to account => any one can send ETH to the account

    function deposit(address to) public payable {
        require(accounts[to].exists, "Recipient account does not exist");

        require(msg.value > 0, "Must send ETH to deposit");

        accounts[to].balance += msg.value;

        _addTransactionHistory(msg.sender, to, TxType.Deposit, msg.value);

        emit DepositMade(msg.sender, to, msg.value);
    }

    // function to withdraw the account balance => only account owner can preforme

    // hmmm ai explain to me the dif betwen call and transfer

    function withdraw(uint256 amount) public onlyAccountOwner {
        // 1. Checks
        require(accounts[msg.sender].balance >= amount, "Insufficient balance");

        // 2. Effects
        accounts[msg.sender].balance -= amount;
        _addTransactionHistory(msg.sender, msg.sender, TxType.Withdraw, amount);

        // 3. Interactions
        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit WithdrawalMade(msg.sender, amount);
    }

    // function to get transaction history => only account owner can preforme
    function getTransactionHistory() public view onlyAccountOwner returns (string[] memory) {
        require(accounts[msg.sender].exists, "Account does not exist");
        return accounts[msg.sender].txHistory;
    }

    // function to clear the transaction history => only account owner can preforme
    function clearHistory() public onlyAccountOwner {
        accounts[msg.sender].txHistory = new string[](0);
    }

    // function to check the account balance => only account owner can preforme

    function viewBalance() public view onlyAccountOwner returns (uint256) {
        return accounts[msg.sender].balance;
    }

    // function to transfer values betwen accounts => only account owner can preforme

    function transferTo(address to, uint256 amount) public onlyAccountOwner {
        require(accounts[to].exists, "Account does not exist");

        require(accounts[msg.sender].balance >= amount, "Insufficient balance");

        accounts[msg.sender].balance -= amount;
        accounts[to].balance += amount;
        _addTransactionHistory(msg.sender, to, TxType.Transfer, amount);

        emit TransferMade(msg.sender, to, amount);
    }

    // function to get account details

    function getAccountDetails(address owner)
        public
        view
        accountdoesNotExists(owner)
        onlyAccountOwner
        returns (address, string memory, uint256, bool)
    {
        require(accounts[owner].exists, "Account does not exist");

        require(accounts[msg.sender].owner == owner, "Not your account");

        Account memory account = accounts[owner];
        return (account.owner, account.name, account.balance, account.exists);
    }

    // Private methods

    // add transaction history to the account
    function _addTransactionHistory(address from, address to, TxType txType, uint256 amount) private {

        // check if the transaction history length is greater than 30 and if it is, remove the oldest transaction
        _checkTransactionHistoryLength(from);
        _checkTransactionHistoryLength(to);

        // convert the timestamp, amount, from, and to to strings
        string memory timestamp = block.timestamp.toString();
        string memory amountStr = amount.toString();
        string memory fromStr = from.toHexString();
        string memory toStr = to.toHexString();
        
        if (txType == TxType.Deposit) {
            if (to == msg.sender) {
                accounts[to].txHistory
                    .push(string(abi.encodePacked("Deposit: ", amountStr, " to self", " on: ", timestamp)));
            } else {
                accounts[to].txHistory
                    .push(string(abi.encodePacked("Deposit: ", amountStr, " to ", toStr, " on: ", timestamp)));
            }
        } else if (txType == TxType.Withdraw) {
            accounts[from].txHistory.push(string(abi.encodePacked("Withdraw: ", amountStr, " on: ", timestamp)));
        } else if (txType == TxType.Transfer) {
            accounts[from].txHistory
                .push(string(abi.encodePacked("Transfer: ", amountStr, " to ", toStr, " on: ", timestamp)));
            accounts[to].txHistory
                .push(string(abi.encodePacked("Transfer: ", amountStr, " from ", fromStr, " on: ", timestamp)));
        }
    }


    // check if the transaction history length is greater than 30 and if it is, remove the oldest transaction
    function _checkTransactionHistoryLength(address accountOwner) private {
        if (accounts[accountOwner].txHistory.length >= 30) {
            accounts[accountOwner].txHistory.pop();
        }
    }


}
