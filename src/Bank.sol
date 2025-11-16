// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract Bank {
    // Define the Account struct

    struct Account {
        address owner;
        string name;
        uint256 balance;
        bool exists;
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

        accounts[msg.sender] = Account({owner: msg.sender, name: _name, balance: 0, exists: true});

        emit AccountCreated(msg.sender, _name);
    }

    // function to deposit to account => any one can send ETH to the account

    function deposit(address to) public payable {
        require(accounts[to].exists, "Recipient account does not exist");

        require(msg.value > 0, "Must send ETH to deposit");

        accounts[to].balance += msg.value;

        emit DepositMade(msg.sender, to, msg.value);
    }

    // function to withdraw the account balance => only account owner can preforme

    // hmmm ai explain to me the dif betwen call and transfer

    function withdraw(uint256 amount) public onlyAccountOwner {
        // 1. Checks
        require(accounts[msg.sender].balance >= amount, "Insufficient balance");

        // 2. Effects
        accounts[msg.sender].balance -= amount;

        // 3. Interactions
        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit WithdrawalMade(msg.sender, amount);
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
}
