
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;
    address public owner;
    address public alice;
    address public bob;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    function setUp() public {
        owner = address(this);
        alice = address(0xABCD);
        bob = address(0xDCBA);
        
        // Fund test accounts
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
        
        vault = new Vault();
    }

    function testDeposit() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();
        assertEq(vault.getBalance(alice), 1 ether);
    }

    function testWithdraw() public {
        // Setup: Alice deposits 1 ETH
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        // Alice withdraws 0.5 ETH
        vm.prank(alice);
        vault.withdraw(0.5 ether);
        assertEq(vault.getBalance(alice), 0.5 ether);
    }

    function testPause() public {
        vault.pause();
        vm.prank(alice);
        vm.expectRevert("Pausable: paused");
        vault.deposit{value: 1 ether}();
    }

    function testOnlyOwnerCanPause() public {
        vm.prank(alice);
        vm.expectRevert("Ownable: caller is not owner");
        vault.pause();
    }

    function testReentrancyProtection() public {
        // Deploy malicious contract
        ReentrancyAttacker attacker = new ReentrancyAttacker(vault);
        
        // Fund attacker
        vm.deal(address(attacker), 1 ether);
        
        // Attempt attack
        vm.expectRevert();
        attacker.attack{value: 1 ether}();
    }

    function testEmitsDepositEvent() public {
        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit Deposited(alice, 1 ether);
        vault.deposit{value: 1 ether}();
    }
}

// Helper contract for testing reentrancy
contract ReentrancyAttacker {
    Vault public vault;
    uint256 public count;

    constructor(Vault _vault) {
        vault = _vault;
    }

    function attack() external payable {
        vault.deposit{value: msg.value}();
        vault.withdraw(msg.value);
    }

    receive() external payable {
        if (count < 2) {
            count++;
            vault.withdraw(msg.value);
        }
    }
}