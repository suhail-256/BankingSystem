// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";

contract BankTest is Test {
    // instance of the contract

    Bank public bank;

    // actors

    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);

    // setup function

    function setUp() public {
        // deploy the contract and store it at bank variable

        bank = new Bank();

        // fund the users with ether

        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);
    }

    // test create account function

    function testCreateAccount() public {
        // set the msg.sender to user1

        vm.prank(user1);

        // user1 creates an account with name "Alice"

        bank.createAccount("Alice");

        // retrieve the account details of user1
        // ensure the call is made as user1 since getAccountDetails uses onlyAccountOwner
        vm.prank(user1);
        (address owner, string memory name, uint256 balance, bool exists) = bank.getAccountDetails(user1);

        // assert the account details

        assertEq(owner, user1);
        assertEq(name, "Alice");
        assertEq(balance, 0);
        assertEq(exists, true);
    }

    // test create account twice should revert
    function testCreateAccountTwice() public {
        // set the msg.sender to user1

        vm.prank(user1);

        // user1 creates an account with name "Alice"

        bank.createAccount("Alice");

        // try to create account again and expect revert

        vm.prank(user1);
        vm.expectRevert("Account already exists");
        bank.createAccount("Alice");
    }

    // test deposit function

    function testdeposit() public {
        // set the msg.sender to user1 and create account

        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 to deposit to user1's account

        vm.prank(user2);

        // user2 deposits 1 ether to user1's account

        bank.deposit{value: 1 ether}(user1);

        // retrieve the account details of user1
        vm.prank(user1);
        (,, uint256 balance,) = bank.getAccountDetails(user1);

        // assert the balance

        assertEq(balance, 1 ether);
    }

    // test deposit to non-existent account should revert

    function testDepositToNonExistentAccount() public {
        // set the msg.sender to user2 to deposit to user1's account

        vm.prank(user2);

        // user2 deposits 1 ether to user1's account which does not exist

        vm.expectRevert("Recipient account does not exist");
        bank.deposit{value: 1 ether}(user1);
    }

    // test deposit zero ether should revert

    function testDepositZeroEther() public {
        // set the msg.sender to user1 and create account

        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 to deposit to user1's account

        vm.prank(user2);

        // user2 deposits 0 ether to user1's account

        vm.expectRevert("Must send ETH to deposit");
        bank.deposit{value: 0 ether}(user1);
    }

    // test withdraw function

    function testwithdraw() public {
        // set the msg.sender to user1 and create account

        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 to deposit to user1's account

        vm.prank(user2);

        // user2 deposits 5 ether to user1's account

        bank.deposit{value: 5 ether}(user1);

        // set the msg.sender to user1 to withdraw

        vm.prank(user1);

        // user1 withdraws 3 ether

        bank.withdraw(3 ether);

        // retrieve the account details of user1
        vm.prank(user1);
        (,, uint256 balance,) = bank.getAccountDetails(user1);

        // assert the balance

        assertEq(balance, 2 ether);
    }

    // test withdraw more than balance should revert

    function testWithdrawMoreThanBalance() public {
        // set the msg.sender to user1 and create account

        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 to deposit to user1's account

        vm.prank(user2);

        // user2 deposits 2 ether to user1's account

        bank.deposit{value: 2 ether}(user1);

        // set the msg.sender to user1 to withdraw

        vm.prank(user1);

        // user1 withdraws 3 ether which is more than balance

        vm.expectRevert("Insufficient balance");
        bank.withdraw(3 ether);
    }
    // test withdraw by non-account owner should revert

    function testWithdrawByNonAccountOwner() public {
        // set the msg.sender to user1 and create account

        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 to deposit to user1's account

        vm.prank(user2);

        // user2 deposits 2 ether to user1's account

        bank.deposit{value: 2 ether}(user1);

        // set the msg.sender to user3 to withdraw from user1's account

        vm.prank(user3);

        // user3 tries to withdraw 1 ether from user1's account

        vm.expectRevert("Not your account");
        bank.withdraw(1 ether);
    }

    // transfer test
    function testTransferTo() public {
        // set the msg.sender to user1 and create account

        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 and create account

        vm.prank(user2);
        bank.createAccount("Bob");

        // set the msg.sender to user1 to deposit to own account

        vm.prank(user1);

        // user1 deposits 5 ether to own account

        bank.deposit{value: 5 ether}(user1);

        // set the msg.sender to user1 to transfer to user2

        vm.prank(user1);

        // user1 transfers 3 ether to user2

        bank.transferTo(user2, 3 ether);

        // retrieve the account details of user1
        vm.prank(user1);
        (,, uint256 balance1,) = bank.getAccountDetails(user1);

        // retrieve the account details of user2
        vm.prank(user2);
        (,, uint256 balance2,) = bank.getAccountDetails(user2);

        // assert the balances

        assertEq(balance1, 2 ether);
        assertEq(balance2, 3 ether);
    }
    // transfer to non-existent account should revert

    function testTransferToNonExistentAccount() public {
        // set the msg.sender to user1 and create account

        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user1 to deposit to own account

        vm.prank(user1);

        // user1 deposits 5 ether to own account

        bank.deposit{value: 5 ether}(user1);

        // set the msg.sender to user1 to transfer to user2

        vm.prank(user1);

        // user1 transfers 3 ether to user2 which does not have an account

        vm.expectRevert("Account does not exist");
        bank.transferTo(user2, 3 ether);
    }

    // transfer more than balance should revert

    function testTransferMoreThanBalance() public {
        // set the msg.sender to user1 and create account

        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 and create account

        vm.prank(user2);
        bank.createAccount("Bob");

        // set the msg.sender to user1 to deposit to own account

        vm.prank(user1);

        // user1 deposits 2 ether to own account

        bank.deposit{value: 2 ether}(user1);

        // set the msg.sender to user1 to transfer to user2

        vm.prank(user1);

        // user1 transfers 3 ether to user2 which is more than balance

        vm.expectRevert("Insufficient balance");
        bank.transferTo(user2, 3 ether);
    }

    // test to get account details by non-account owner should revert

    function testGetAccountDetailsByNonAccountOwner() public {
        // set the msg.sender to user1 and create account

        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 to get account details of user1

        vm.prank(user2);

        // user2 tries to get account details of user1

        vm.expectRevert("Not your account");
        bank.getAccountDetails(user1);
    }

    // test to get account details of non-existent account should revert

    function testGetAccountDetailsOfNonExistentAccount() public {
        // set the msg.sender to user1 to get account details of user2

        vm.prank(user1);

        // user1 tries to get account details of user2 which does not have an account

        vm.expectRevert("Account does not exist");

        bank.getAccountDetails(user2);
    }

    // test view balance

    function testViewBalance() public {
        // set the msg.sender to user1 and create account

        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 to deposit to user1's account

        vm.prank(user2);

        // user2 deposits 4 ether to user1's account

        bank.deposit{value: 4 ether}(user1);

        // set the msg.sender to user1 to view balance

        vm.prank(user1);

        // user1 views balance

        uint256 balance = bank.viewBalance();

        // assert the balance

        assertEq(balance, 4 ether);
    }

    // view balance by non-account owner should revert

    function testViewBalanceByNonAccountOwner() public {
        // set the msg.sender to user1 and create account

        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 to view balance of user1

        vm.prank(user2);

        // user2 tries to view balance of user1

        vm.expectRevert("Not your account");
        bank.viewBalance();
    }

    // ========== Transaction History Tests ==========

    // test get transaction history after deposit
    function testGetTransactionHistoryAfterDeposit() public {
        console.log("Testing transaction history after deposit");

        // set the msg.sender to user1 and create account
        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 to deposit to user1's account
        vm.prank(user2);
        bank.deposit{value: 2 ether}(user1);

        // get transaction history for user1
        vm.prank(user1);
        string[] memory history = bank.getTransactionHistory();

        // assert the history length
        assertEq(history.length, 1);
        console.log("Transaction history length:", history.length);
        console.log("First transaction:", history[0]);

        // verify the transaction contains deposit info
        assertTrue(bytes(history[0]).length > 0);
    }

    // test get transaction history after withdraw
    function testGetTransactionHistoryAfterWithdraw() public {
        console.log("Testing transaction history after withdraw");

        // set the msg.sender to user1 and create account
        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 to deposit to user1's account
        vm.prank(user2);
        bank.deposit{value: 5 ether}(user1);

        // set the msg.sender to user1 to withdraw
        vm.prank(user1);
        bank.withdraw(2 ether);

        // get transaction history for user1
        vm.prank(user1);
        string[] memory history = bank.getTransactionHistory();

        // assert the history length (should have deposit and withdraw)
        assertEq(history.length, 2);
        console.log("Transaction history length:", history.length);
        console.log("First transaction:", history[0]);
        console.log("Second transaction:", history[1]);

        // verify both transactions exist
        assertTrue(bytes(history[0]).length > 0);
        assertTrue(bytes(history[1]).length > 0);
    }

    // test get transaction history after transfer
    function testGetTransactionHistoryAfterTransfer() public {
        console.log("Testing transaction history after transfer");

        // set the msg.sender to user1 and create account
        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 and create account
        vm.prank(user2);
        bank.createAccount("Bob");

        // set the msg.sender to user1 to deposit to own account
        vm.prank(user1);
        bank.deposit{value: 5 ether}(user1);

        // set the msg.sender to user1 to transfer to user2
        vm.prank(user1);
        bank.transferTo(user2, 3 ether);

        // get transaction history for user1 (sender)
        vm.prank(user1);
        string[] memory history1 = bank.getTransactionHistory();

        // get transaction history for user2 (receiver)
        vm.prank(user2);
        string[] memory history2 = bank.getTransactionHistory();

        // assert the history lengths
        assertEq(history1.length, 2); // deposit + transfer out
        assertEq(history2.length, 1); // transfer in

        console.log("User1 transaction history length:", history1.length);
        console.log("User2 transaction history length:", history2.length);
        console.log("User1 first transaction:", history1[0]);
        console.log("User1 second transaction:", history1[1]);
        console.log("User2 first transaction:", history2[0]);
    }

    // test clear transaction history
    function testClearTransactionHistory() public {
        console.log("Testing clear transaction history");

        // set the msg.sender to user1 and create account
        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 to deposit to user1's account
        vm.prank(user2);
        bank.deposit{value: 2 ether}(user1);

        // set the msg.sender to user1 to withdraw
        vm.prank(user1);
        bank.withdraw(1 ether);

        // verify history has 2 transactions
        vm.prank(user1);
        string[] memory historyBefore = bank.getTransactionHistory();
        assertEq(historyBefore.length, 2);
        console.log("History length before clear:", historyBefore.length);

        // clear the history
        vm.prank(user1);
        bank.clearHistory();

        // verify history is empty
        vm.prank(user1);
        string[] memory historyAfter = bank.getTransactionHistory();
        assertEq(historyAfter.length, 0);
        console.log("History length after clear:", historyAfter.length);
    }

    // test get transaction history by non-account owner should revert
    function testGetTransactionHistoryByNonAccountOwner() public {
        console.log("Testing get transaction history by non-account owner");

        // set the msg.sender to user1 and create account
        vm.prank(user1);
        bank.createAccount("Alice");

        // set the msg.sender to user2 (who doesn't have an account) to get transaction history
        vm.prank(user2);

        // user2 tries to get transaction history but doesn't have an account
        vm.expectRevert("Not your account");
        bank.getTransactionHistory();
    }

    // test get transaction history of non-existent account should revert
    function testGetTransactionHistoryOfNonExistentAccount() public {
        console.log("Testing get transaction history of non-existent account");

        // set the msg.sender to user1 (who doesn't have an account) to get transaction history
        vm.prank(user1);

        // user1 tries to get transaction history but doesn't have an account
        vm.expectRevert("Not your account");
        bank.getTransactionHistory();
    }
}
