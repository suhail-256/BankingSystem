// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
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
}
