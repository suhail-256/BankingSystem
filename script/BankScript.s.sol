// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Bank.sol";

// Foundry script to deploy the Bank contract and perform example interactions.
// How to run (local/demo):
// 1) Run without broadcasting to a live network (uses cheatcodes):
//    forge script script/Deploy.s.sol --fork-url <RPC> -vvvv
// 2) Broadcast to a network (you must provide PRIVATE_KEY or --private-key):
//    forge script script/Deploy.s.sol --broadcast --private-key <KEY> -vvvv
// Note: This script uses cheatcodes (vm.deal, vm.prank). When broadcasting to a
// public network, cheatcodes won't work; use this script mainly for local/forked runs.

contract DeployScript is Script {
    function run() external {
        // example addresses (matching your tests)
        address user1 = address(0x1);
        address user2 = address(0x2);
        address user3 = address(0x3);

        // Fund the example accounts (cheatcode - works in local/forked runs)
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);

        // Deploy the Bank contract
        vm.startBroadcast();
        Bank bank = new Bank();
        vm.stopBroadcast();

        // -- Example interactions (use vm.prank to simulate calls from different accounts) --
        // Create accounts for user1 and user2
        vm.startBroadcast();
        vm.prank(user1);
        bank.createAccount("Alice");

        vm.prank(user2);
        bank.createAccount("Bob");

        // user2 deposits 5 ETH into user1's account
        vm.prank(user2);
        bank.deposit{value: 5 ether}(user1);

        // user1 withdraws 1 ETH
        vm.prank(user1);
        bank.withdraw(1 ether);

        // user1 transfers 2 ETH to user2
        vm.prank(user1);
        bank.transferTo(user2, 2 ether);

        vm.stopBroadcast();

        // -- Read balances and print to console (use pranks so getAccountDetails/viewBalance uses msg.sender) --
        vm.prank(user1);
        (address o1, string memory n1, uint256 balance1, bool e1) = bank
            .getAccountDetails(user1);
        console.log("User1 => owner:", o1);
        console.log("User1 => name:", n1);
        console.log("User1 => balance:", balance1);
        console.log("User1 => exists:", e1 ? 1 : 0);

        vm.prank(user2);
        (address o2, string memory n2, uint256 balance2, bool e2) = bank
            .getAccountDetails(user2);
        console.log("User2 => owner:", o2);
        console.log("User2 => name:", n2);
        console.log("User2 => balance:", balance2);
        console.log("User2 => exists:", e2 ? 1 : 0);

        // Example: viewBalance() for user1
        vm.prank(user1);
        uint256 viewBal1 = bank.viewBalance();
        console.log("viewBalance(user1) =", viewBal1);

        // end of script
    }
}
