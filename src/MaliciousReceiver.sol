// SPDX-License-Identifier: MIT 

// My Contract

pragma solidity ^0.8.10;

import {Vault} from  "./Vault.sol";

/// @title A title that should describe the contract/interface
/// @author Gintoki Sakata
/// @notice This contract exists solely to sabotage Vault.withdraw() by failing the .call.
/// @dev Behavior:
/// It has a fallback() or receive() that reverts intentionally.
///  It has a function to deposit into the Vault.
/// It has a function to withdraw from the Vault, triggering the fallback.
/// It should store a reference to the Vault contract.
contract MaliciousReceiver {

    Vault public vault;

    constructor(Vault _vault){
        vault = _vault;
    }
    
    function depositIntoVault() external payable {
        vault.deposit{value : msg.value}();
    }

    function triggerWithdraw() external {
        vault.withdraw();
    }

    fallback() external payable {
        revert("Don't accept ETH");
    }
}