// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test, console2} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {VaultHandler} from "../src/VaultHandler.sol";
import {Vault} from "../src/Vault.sol";

contract VaultInvariantTest is StdInvariant, Test {
    Vault public vault;
    VaultHandler public handler;

    function setUp() public {
        vault = new Vault();
        handler = new VaultHandler(vault);

        targetContract(address(handler)); // Foundry will randomly call handler's methods
    }

    function invariant_sumOfBalancesEqualsVaultBalance() public {
        address[] memory users = handler.getUsers();
        uint256 totalUserBalances;

        for (uint256 i = 0; i < users.length; i++) {
            totalUserBalances += vault.balances(users[i]);
        }

        uint256 vaultAssets = vault.totalAssets();
        assertEq(totalUserBalances, vaultAssets, "Vault balance mismatch");
    }
}
