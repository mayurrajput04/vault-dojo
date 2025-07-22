// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Vault} from "./Vault.sol";

// Foundry cheatcodes interface
interface Vm {
    function deal(address who, uint256 newBalance) external;
    function prank(address sender) external;
}

contract VaultHandler {
    Vault public vault;
    address[] public users;
    mapping(address => bool) public hasDeposited;

    // Cheatcodes available in the testing environment
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    constructor(Vault _vault) {
        vault = _vault;

        // Initialize users upfront (5 test addresses)
        for (uint256 i = 0; i < 5; i++) {
            users.push(address(uint160(0x100 + i)));
        }
    }

    // Helper to bound a value between min and max
    function bound(uint256 x, uint256 min, uint256 max) internal pure returns (uint256) {
        if (x < min) return min;
        if (x > max) return max;
        return x;
    }

    // Deposit ETH to vault from one of the test users
    function deposit(uint256 amount) public {
        if (amount == 0) return;

        // Pick a user deterministically from fuzzed msg.sender
        address user = users[bound(uint256(uint160(msg.sender)), 0, users.length - 1)];

        vm.deal(user, amount); // fund them
        vm.prank(user);
        vault.deposit{value: amount}();

        hasDeposited[user] = true;
    }

    // Withdraw funds from vault for one of the users
    function withdraw() public {
        address user = users[bound(uint256(uint160(msg.sender)), 0, users.length - 1)];

        vm.prank(user);
        try vault.withdraw() {} catch {
            // skip if withdrawal fails
        }
    }

    // Return list of users who have deposited
    function getUsers() external view returns (address[] memory activeUsers) {
        uint256 count;

        for (uint256 i = 0; i < users.length; i++) {
            if (hasDeposited[users[i]]) {
                count++;
            }
        }

        activeUsers = new address[](count);
        uint256 index;

        for (uint256 i = 0; i < users.length; i++) {
            if (hasDeposited[users[i]]) {
                activeUsers[index] = users[i];
                index++;
            }
        }
    }
}
