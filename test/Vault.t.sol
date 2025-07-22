    // SPDX-License-Identifier: MIT 

    pragma solidity ^0.8.10;

    import { Test, console } from "forge-std/Test.sol";
    import { Vault } from "../src/Vault.sol";
    import { MaliciousReceiver } from "../src/MaliciousReceiver.sol";

    contract VaultTest is Test {
        Vault public vault;
        MaliciousReceiver public falseReceiver;
        address payable public vaultAddress;

        address user = makeAddr("USER");
        uint256 amount = 1e18;

        function setUp() public {
            vault = new Vault();
            falseReceiver = new MaliciousReceiver(vault);
            
            vm.deal(address(user), amount);
            vm.deal(address(falseReceiver), amount);
            vaultAddress = payable(address(vault));
        }

        function testDepositUpdatesBalanceCorrectly() public {
            vm.prank(user);
            vault.deposit{value : amount}();
            assert(vault.balances(user) == amount );
        }

        function testWithdrawSendsETHAndResetsBalance() public {
            vm.startPrank(user);

            vault.deposit{value : amount}();
            uint256 balanceBefore = address(user).balance;

            vault.withdraw();
            
            uint256 balanceAfter = address(user).balance;
            vm.stopPrank();

            assert(vault.balances(user) == 0);
            assertEq(balanceAfter , balanceBefore + amount);
        }

        function testTotalAssetsReturnsCorrectETH() public {
            vm.prank(user);
            vault.deposit{value : amount}();
            uint256 totalEth = vault.totalAssets();

            assert(totalEth == address(vault).balance);
        }

        function testTotalAssetsWithMultipleDeposits() public {
            address  user1 = makeAddr("USER1") ;
            address  user2 = makeAddr("USER2") ;

            vm.deal(user1 , amount);
            vm.deal(user2 , amount);

            vm.prank(user1);
            vault.deposit{value: amount}();

            vm.prank(user2);
            vault.deposit{value: amount}();

            uint256 totalAmount = vault.totalAssets();
            uint256 expectedAmount = 2 ether ;
            assert(totalAmount == expectedAmount);

        }

        function testTotalAssetsAfterWithdraw() public {
            vm.startPrank(user);
            vault.deposit{value:amount}();
            vault.withdraw();
            vm.stopPrank();
            uint256 totalAmount = vault.totalAssets();

            assert(totalAmount == 0);
        }

        function testRevertsOnZeroDeposit() public {
            address user1 = makeAddr("USER1");
            uint256 userBalance = 0 ether ;
            vm.prank(user1);
            vm.expectRevert(Vault.ZeroDeposit.selector);
            vault.deposit{value : userBalance}();

        }

        function testRevertsOnDoubleWithdrawal() public {
            vm.startPrank(user);
            vault.deposit{value:amount}();
            vault.withdraw();
            vm.expectRevert(Vault.NoBalance.selector);
            vault.withdraw();
        }

        function testVaultRevertsOnCallFailure() public {
            vm.prank(address(falseReceiver));
            falseReceiver.depositIntoVault{value: 1 ether}();
            vm.expectRevert(Vault.SendFailed.selector);
            falseReceiver.triggerWithdraw();

        }

    }