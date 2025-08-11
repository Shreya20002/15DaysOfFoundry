// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SimpleBank} from "../src/SimpleBank.sol";

contract SimpleBankTest is Test {
    SimpleBank public bank;
    address public owner;
    address public alice;
    address public bob;
    address public charlie;
    
    // Events to test
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);
    event Withdrawal(address indexed user, uint256 amount, uint256 newBalance);
    event AccountCreated(address indexed user);
    
    function setUp() public {
        // Set up test accounts
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");
        
        // Deploy the contract
        bank = new SimpleBank();
        
        // Give test accounts some ETH
        vm.deal(alice, 100 ether);
        vm.deal(bob, 50 ether);
        vm.deal(charlie, 25 ether);
    }
    
    // ============ BASIC FUNCTIONALITY TESTS ============
    
    function test_InitialState() public {
        assertEq(bank.owner(), owner);
        assertEq(bank.totalDeposits(), 0);
        assertEq(bank.getContractBalance(), 0);
        assertEq(bank.getTotalAccountHolders(), 0);
        assertFalse(bank.hasAccount(alice));
    }
    
    function test_Deposit() public {
        uint256 depositAmount = 5 ether;
        
        // Expect events
        vm.expectEmit(true, false, false, true);
        emit AccountCreated(alice);
        
        vm.expectEmit(true, false, false, true);
        emit Deposit(alice, depositAmount, depositAmount);
        
        // Make deposit
        vm.prank(alice);
        bank.deposit{value: depositAmount}();
        
        // Check state
        assertEq(bank.getBalanceOf(alice), depositAmount);
        assertEq(bank.totalDeposits(), depositAmount);
        assertEq(bank.getContractBalance(), depositAmount);
        assertEq(bank.getTotalAccountHolders(), 1);
        assertTrue(bank.hasAccount(alice));
    }
    
    function test_MultipleDeposits() public {
        uint256 deposit1 = 3 ether;
        uint256 deposit2 = 2 ether;
        uint256 totalDeposit = deposit1 + deposit2;
        
        // First deposit
        vm.prank(alice);
        bank.deposit{value: deposit1}();
        
        // Second deposit (should not create new account)
        vm.prank(alice);
        bank.deposit{value: deposit2}();
        
        assertEq(bank.getBalanceOf(alice), totalDeposit);
        assertEq(bank.getTotalAccountHolders(), 1); // Still only 1 account
    }
    
    function test_Withdraw() public {
        uint256 depositAmount = 10 ether;
        uint256 withdrawAmount = 4 ether;
        uint256 expectedBalance = depositAmount - withdrawAmount;
        
        // Make deposit first
        vm.prank(alice);
        bank.deposit{value: depositAmount}();
        
        uint256 aliceBalanceBefore = alice.balance;
        
        // Expect withdrawal event
        vm.expectEmit(true, false, false, true);
        emit Withdrawal(alice, withdrawAmount, expectedBalance);
        
        // Make withdrawal
        vm.prank(alice);
        bank.withdraw(withdrawAmount);
        
        // Check balances
        assertEq(bank.getBalanceOf(alice), expectedBalance);
        assertEq(alice.balance, aliceBalanceBefore + withdrawAmount);
        assertEq(bank.totalDeposits(), expectedBalance);
    }
    
    function test_WithdrawAll() public {
        uint256 depositAmount = 7 ether;
        
        // Make deposit
        vm.prank(alice);
        bank.deposit{value: depositAmount}();
        
        uint256 aliceBalanceBefore = alice.balance;
        
        // Withdraw all
        vm.prank(alice);
        bank.withdrawAll();
        
        // Check balances
        assertEq(bank.getBalanceOf(alice), 0);
        assertEq(alice.balance, aliceBalanceBefore + depositAmount);
        assertEq(bank.totalDeposits(), 0);
    }
    
    // ============ EDGE CASES AND ERROR HANDLING ============
    
    function test_RevertDepositZeroAmount() public {
        vm.prank(alice);
        vm.expectRevert("Amount must be greater than zero");
        bank.deposit{value: 0}();
    }
    
    function test_RevertWithdrawZeroAmount() public {
        vm.prank(alice);
        vm.expectRevert("Amount must be greater than zero");
        bank.withdraw(0);
    }
    
    function test_RevertWithdrawWithoutAccount() public {
        vm.prank(alice);
        vm.expectRevert("Account does not exist");
        bank.withdraw(1 ether);
    }
    
    function test_RevertWithdrawInsufficientBalance() public {
        // Alice deposits 5 ETH
        vm.prank(alice);
        bank.deposit{value: 5 ether}();
        
        // Try to withdraw 10 ETH
        vm.prank(alice);
        vm.expectRevert("Insufficient balance");
        bank.withdraw(10 ether);
    }
    
    function test_RevertWithdrawAllWithoutFunds() public {
        // Create account with deposit
        vm.prank(alice);
        bank.deposit{value: 5 ether}();
        
        // Withdraw all funds
        vm.prank(alice);
        bank.withdrawAll();
        
        // Try to withdraw all again
        vm.prank(alice);
        vm.expectRevert("No funds to withdraw");
        bank.withdrawAll();
    }
    
    function test_RevertDirectEtherTransfer() public {
        vm.prank(alice);
        vm.expectRevert("Use deposit() function to send Ether");
        payable(address(bank)).transfer(1 ether);
    }
    
    function test_RevertFallback() public {
        vm.prank(alice);
        vm.expectRevert("Function does not exist");
        (bool success, ) = address(bank).call{value: 1 ether}("nonExistentFunction()");
        assertFalse(success);
    }
    
    // ============ MULTIPLE USERS TESTS ============
    
    function test_MultipleUsers() public {
        // Alice deposits 10 ETH
        vm.prank(alice);
        bank.deposit{value: 10 ether}();
        
        // Bob deposits 5 ETH
        vm.prank(bob);
        bank.deposit{value: 5 ether}();
        
        // Charlie deposits 3 ETH
        vm.prank(charlie);
        bank.deposit{value: 3 ether}();
        
        // Check individual balances
        assertEq(bank.getBalanceOf(alice), 10 ether);
        assertEq(bank.getBalanceOf(bob), 5 ether);
        assertEq(bank.getBalanceOf(charlie), 3 ether);
        
        // Check total state
        assertEq(bank.totalDeposits(), 18 ether);
        assertEq(bank.getTotalAccountHolders(), 3);
        assertEq(bank.getContractBalance(), 18 ether);
    }
    
    function test_UserAccountInfo() public {
        // Check non-existent account
        (bool exists, uint256 balance) = bank.getUserAccountInfo(alice);
        assertFalse(exists);
        assertEq(balance, 0);
        
        // Create account and check
        vm.prank(alice);
        bank.deposit{value: 5 ether}();
        
        (exists, balance) = bank.getUserAccountInfo(alice);
        assertTrue(exists);
        assertEq(balance, 5 ether);
    }
    
    // ============ OWNER-ONLY FUNCTIONS TESTS ============
    
    function test_OnlyOwnerCanGetAccountHolders() public {
        // Owner can access
        address[] memory holders = bank.getAccountHolders();
        assertEq(holders.length, 0);
        
        // Non-owner cannot access
        vm.prank(alice);
        vm.expectRevert("Only owner can call this function");
        bank.getAccountHolders();
    }
    
    function test_EmergencyPauseAndUnpause() public {
        // Deposit first
        vm.prank(alice);
        bank.deposit{value: 5 ether}();
        
        // Owner pauses
        bank.emergencyPause();
        
        // Operations should fail
        vm.prank(alice);
        vm.expectRevert("Reentrancy detected");
        bank.withdraw(1 ether);
        
        vm.prank(bob);
        vm.expectRevert("Reentrancy detected");
        bank.deposit{value: 1 ether}();
        
        // Owner unpauses
        bank.emergencyUnpause();
        
        // Operations should work again
        vm.prank(alice);
        bank.withdraw(1 ether);
        
        vm.prank(bob);
        bank.deposit{value: 1 ether}();
        
        assertEq(bank.getBalanceOf(alice), 4 ether);
        assertEq(bank.getBalanceOf(bob), 1 ether);
    }
    
    function test_OnlyOwnerCanPause() public {
        vm.prank(alice);
        vm.expectRevert("Only owner can call this function");
        bank.emergencyPause();
    }
    
    // ============ FUZZING TESTS ============
    
    function testFuzz_Deposit(uint256 amount) public {
        // Bound the amount to reasonable values
        amount = bound(amount, 1 wei, 1000 ether);
        
        // Give alice enough ether
        vm.deal(alice, amount);
        
        vm.prank(alice);
        bank.deposit{value: amount}();
        
        assertEq(bank.getBalanceOf(alice), amount);
        assertEq(bank.totalDeposits(), amount);
    }
    
    function testFuzz_DepositAndWithdraw(uint256 depositAmount, uint256 withdrawAmount) public {
        // Bound amounts
        depositAmount = bound(depositAmount, 1 ether, 100 ether);
        withdrawAmount = bound(withdrawAmount, 1 wei, depositAmount);
        
        // Give alice enough ether
        vm.deal(alice, depositAmount);
        
        // Deposit
        vm.prank(alice);
        bank.deposit{value: depositAmount}();
        
        uint256 aliceBalanceBefore = alice.balance;
        
        // Withdraw
        vm.prank(alice);
        bank.withdraw(withdrawAmount);
        
        assertEq(bank.getBalanceOf(alice), depositAmount - withdrawAmount);
        assertEq(alice.balance, aliceBalanceBefore + withdrawAmount);
    }
    
    // ============ STRESS TESTS ============
    
    function test_ManyUsersDeposit() public {
        uint256 numUsers = 10;
        
        for (uint256 i = 0; i < numUsers; i++) {
            address user = makeAddr(string(abi.encodePacked("user", i)));
            vm.deal(user, 10 ether);
            
            vm.prank(user);
            bank.deposit{value: 1 ether}();
        }
        
        assertEq(bank.getTotalAccountHolders(), numUsers);
        assertEq(bank.totalDeposits(), numUsers * 1 ether);
    }
    
    // ============ HELPER FUNCTIONS FOR TESTING ============
    
    function test_GetBalance() public {
        vm.prank(alice);
        bank.deposit{value: 5 ether}();
        
        vm.prank(alice);
        uint256 balance = bank.getBalance();
        
        assertEq(balance, 5 ether);
    }
}
