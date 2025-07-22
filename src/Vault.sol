// SPDX-License-Identifier: MIT 

// My Contract

pragma solidity ^0.8.10;

import { ReentrancyGuard } from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Vault is ReentrancyGuard {
    
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    error ZeroDeposit();
    error NoBalance();
    error SendFailed();


    mapping(address => uint256)  public balances ;

    function deposit() external payable {
        // require(msg.value > 0, "Balance should be greater than zero");
        if ( msg.value == 0 ) {
            revert ZeroDeposit();
        }
        balances[msg.sender] += msg.value ;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw() external nonReentrant() {
        uint256 balance = balances[msg.sender];
        // require(balance > 0 , "zero balance In account ,Nothing to withdraw");
        if( balance == 0 ) {
            revert NoBalance();
        }
        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value : balance}("");
        if(!success) {
            revert SendFailed();
        }
        emit Withdrawn(msg.sender, balance);
    }

    function totalAssets() public view returns(uint256) {
        return address(this).balance ;
    }
}