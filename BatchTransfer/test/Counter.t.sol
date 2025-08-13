// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BatchTransfer} from "../src/Counter.sol";

/**
 * @title BatchTransfer Test Suite with Gas Benchmarking
 * @dev Comprehensive testing and gas optimization benchmarks
 */
contract BatchTransferTest is Test {
    BatchTransfer public batchTransfer;
    
    // Test addresses
    address payable[] recipients;
    uint256[] amounts;
    
    // Events for testing
    event BatchTransferExecuted(
        address indexed sender,
        uint256 totalAmount,
        uint256 recipientCount,
        uint256 gasUsed
    );
    
    function setUp() public {
        batchTransfer = new BatchTransfer();
        
        // Set up test recipients
        recipients.push(payable(makeAddr("alice")));
        recipients.push(payable(makeAddr("bob")));
        recipients.push(payable(makeAddr("charlie")));
        recipients.push(payable(makeAddr("diana")));
        recipients.push(payable(makeAddr("eve")));
        
        // Set up test amounts (in wei)
        amounts.push(1 ether);
        amounts.push(2 ether);
        amounts.push(0.5 ether);
        amounts.push(1.5 ether);
        amounts.push(0.75 ether);
    }
    
    function test_BatchTransferOptimized_Success() public {
        uint256 totalRequired = 5.75 ether;
        
        // Check initial balances
        for (uint256 i = 0; i < recipients.length; i++) {
            assertEq(recipients[i].balance, 0);
        }
        
        // Execute optimized batch transfer
        vm.expectEmit(true, false, false, false);
        emit BatchTransferExecuted(address(this), totalRequired, 5, 0);
        
        batchTransfer.batchTransferOptimized{value: totalRequired}(recipients, amounts);
        
        // Verify transfers
        assertEq(recipients[0].balance, 1 ether);
        assertEq(recipients[1].balance, 2 ether);
        assertEq(recipients[2].balance, 0.5 ether);
        assertEq(recipients[3].balance, 1.5 ether);
        assertEq(recipients[4].balance, 0.75 ether);
        
        // Check contract stats
        (uint256 totalTransfers, ) = batchTransfer.getContractStats();
        assertEq(totalTransfers, 5);
    }
    
    function test_BatchTransferStandard_Success() public {
        uint256 totalRequired = 5.75 ether;
        
        batchTransfer.batchTransferStandard{value: totalRequired}(recipients, amounts);
        
        // Verify transfers
        assertEq(recipients[0].balance, 1 ether);
        assertEq(recipients[1].balance, 2 ether);
        assertEq(recipients[2].balance, 0.5 ether);
        assertEq(recipients[3].balance, 1.5 ether);
        assertEq(recipients[4].balance, 0.75 ether);
    }
    
    function test_BatchTransferUltraOptimized_Success() public {
        uint256 totalRequired = 5.75 ether;
        
        batchTransfer.batchTransferUltraOptimized{value: totalRequired}(recipients, amounts);
        
        // Verify transfers
        assertEq(recipients[0].balance, 1 ether);
        assertEq(recipients[1].balance, 2 ether);
        assertEq(recipients[2].balance, 0.5 ether);
        assertEq(recipients[3].balance, 1.5 ether);
        assertEq(recipients[4].balance, 0.75 ether);
    }
    
    function test_BatchTransferEqual_Success() public {
        uint256 totalSent = 5 ether;
        uint256 expectedEach = 1 ether;
        
        batchTransfer.batchTransferEqual{value: totalSent}(recipients);
        
        // Verify equal distribution
        for (uint256 i = 0; i < recipients.length; i++) {
            assertEq(recipients[i].balance, expectedEach);
        }
    }
    
    function test_RefundExcess() public {
        uint256 totalRequired = 5.75 ether;
        uint256 excess = 1 ether;
        uint256 initialBalance = address(this).balance;
        
        batchTransfer.batchTransferOptimized{value: totalRequired + excess}(recipients, amounts);
        
        // Check refund
        assertEq(address(this).balance, initialBalance - totalRequired);
    }
    
    function test_RevertInsufficientBalance() public {
        uint256 insufficient = 3 ether; // Less than required 5.75 ether
        
        vm.expectRevert(BatchTransfer.InsufficientBalance.selector);
        batchTransfer.batchTransferOptimized{value: insufficient}(recipients, amounts);
    }
    
    function test_RevertArrayLengthMismatch() public {
        uint256[] memory mismatchedAmounts = new uint256[](3); // Different length
        
        vm.expectRevert(BatchTransfer.ArrayLengthMismatch.selector);
        batchTransfer.batchTransferOptimized{value: 5 ether}(recipients, mismatchedAmounts);
    }
    
    function test_RevertEmptyArrays() public {
        address payable[] memory emptyRecipients;
        uint256[] memory emptyAmounts;
        
        vm.expectRevert(BatchTransfer.EmptyArrays.selector);
        batchTransfer.batchTransferOptimized{value: 1 ether}(emptyRecipients, emptyAmounts);
    }
    
    // ===== GAS BENCHMARKING TESTS =====
    
    function test_GasBenchmark_5Recipients() public {
        console2.log("=== Gas Benchmark: 5 Recipients ===");
        uint256 totalRequired = 5.75 ether;
        
        // Optimized version
        uint256 gasOptimized = gasleft();
        batchTransfer.batchTransferOptimized{value: totalRequired}(recipients, amounts);
        gasOptimized = gasOptimized - gasleft();
        
        // Reset balances for fair comparison
        resetRecipientBalances();
        
        // Standard version  
        uint256 gasStandard = gasleft();
        batchTransfer.batchTransferStandard{value: totalRequired}(recipients, amounts);
        gasStandard = gasStandard - gasleft();
        
        // Reset balances
        resetRecipientBalances();
        
        // Ultra optimized version
        uint256 gasUltra = gasleft();
        batchTransfer.batchTransferUltraOptimized{value: totalRequired}(recipients, amounts);
        gasUltra = gasUltra - gasleft();
        
        // Log results
        console2.log("Standard Implementation:     ", gasStandard);
        console2.log("Optimized Implementation:    ", gasOptimized);
        console2.log("Ultra-Optimized Implementation:", gasUltra);
        console2.log("Standard vs Optimized Savings:", gasStandard - gasOptimized);
        console2.log("Standard vs Ultra Savings:   ", gasStandard - gasUltra);
        console2.log("Optimized vs Ultra Savings:  ", gasOptimized - gasUltra);
        
        // Assert optimizations are actually saving gas
        assertLt(gasOptimized, gasStandard, "Optimized should use less gas than standard");
        assertLt(gasUltra, gasOptimized, "Ultra-optimized should use less gas than optimized");
    }
    
    function test_GasBenchmark_10Recipients() public {
        console2.log("\n=== Gas Benchmark: 10 Recipients ===");
        
        // Expand test data
        address payable[] memory recipients10 = new address payable[](10);
        uint256[] memory amounts10 = new uint256[](10);
        uint256 totalRequired10 = 0;
        
        for (uint256 i = 0; i < 10; i++) {
            recipients10[i] = payable(makeAddr(string(abi.encodePacked("user", i))));
            amounts10[i] = (i + 1) * 0.1 ether;
            totalRequired10 += amounts10[i];
        }
        
        // Standard version
        uint256 gasStandard = gasleft();
        batchTransfer.batchTransferStandard{value: totalRequired10}(recipients10, amounts10);
        gasStandard = gasStandard - gasleft();
        
        // Ultra optimized version
        uint256 gasUltra = gasleft();
        batchTransfer.batchTransferUltraOptimized{value: totalRequired10}(recipients10, amounts10);
        gasUltra = gasUltra - gasleft();
        
        console2.log("Standard (10 recipients):    ", gasStandard);
        console2.log("Ultra-Optimized (10 recipients):", gasUltra);
        console2.log("Gas Savings:                 ", gasStandard - gasUltra);
        console2.log("Savings Percentage:          ", (gasStandard - gasUltra) * 100 / gasStandard, "%");
        
        assertLt(gasUltra, gasStandard, "Ultra-optimized should save gas");
    }
    
    function test_GasBenchmark_50Recipients() public {
        console2.log("\n=== Gas Benchmark: 50 Recipients ===");
        
        // Large batch test
        address payable[] memory recipients50 = new address payable[](50);
        uint256[] memory amounts50 = new uint256[](50);
        uint256 totalRequired50 = 0;
        
        for (uint256 i = 0; i < 50; i++) {
            recipients50[i] = payable(makeAddr(string(abi.encodePacked("user", i))));
            amounts50[i] = 0.1 ether;
            totalRequired50 += amounts50[i];
        }
        
        // Only test ultra-optimized for large batches (standard would be too expensive)
        uint256 gasUltra = gasleft();
        batchTransfer.batchTransferUltraOptimized{value: totalRequired50}(recipients50, amounts50);
        gasUltra = gasUltra - gasleft();
        
        console2.log("Ultra-Optimized (50 recipients):", gasUltra);
        console2.log("Gas per recipient:           ", gasUltra / 50);
        
        // Verify large batch succeeded
        assertTrue(gasUltra > 0, "Large batch should consume gas");
    }
    
    function test_GasBenchmark_EqualDistribution() public {
        console2.log("\n=== Gas Benchmark: Equal Distribution ===");
        
        // Equal distribution benchmark
        uint256 gasEqual = gasleft();
        batchTransfer.batchTransferEqual{value: 5 ether}(recipients);
        gasEqual = gasEqual - gasleft();
        
        console2.log("Equal Distribution (5 recipients):", gasEqual);
        console2.log("Gas per recipient (equal):    ", gasEqual / 5);
        
        assertTrue(gasEqual > 0, "Equal distribution should consume gas");
    }
    
    // ===== FUZZ TESTS =====
    
    function testFuzz_BatchTransferOptimized(
        uint8 recipientCount,
        uint256 seed
    ) public {
        // Bound inputs
        recipientCount = uint8(bound(recipientCount, 1, 20));
        
        // Generate recipients and amounts
        address payable[] memory fuzzRecipients = new address payable[](recipientCount);
        uint256[] memory fuzzAmounts = new uint256[](recipientCount);
        uint256 totalRequired = 0;
        
        for (uint256 i = 0; i < recipientCount; i++) {
            fuzzRecipients[i] = payable(makeAddr(string(abi.encodePacked("fuzzUser", i, seed))));
            fuzzAmounts[i] = bound(uint256(keccak256(abi.encode(seed, i))), 0.01 ether, 1 ether);
            totalRequired += fuzzAmounts[i];
        }
        
        // Execute transfer
        batchTransfer.batchTransferOptimized{value: totalRequired}(fuzzRecipients, fuzzAmounts);
        
        // Verify all recipients received correct amounts
        for (uint256 i = 0; i < recipientCount; i++) {
            assertEq(fuzzRecipients[i].balance, fuzzAmounts[i]);
        }
    }
    
    function testFuzz_GasEfficiency(uint8 recipientCount) public {
        recipientCount = uint8(bound(recipientCount, 1, 15));
        
        // Create test data
        address payable[] memory fuzzRecipients = new address payable[](recipientCount);
        uint256[] memory fuzzAmounts = new uint256[](recipientCount);
        uint256 totalRequired = 0;
        
        for (uint256 i = 0; i < recipientCount; i++) {
            fuzzRecipients[i] = payable(makeAddr(string(abi.encodePacked("gasUser", i))));
            fuzzAmounts[i] = 0.1 ether; // Fixed amount for fair comparison
            totalRequired += fuzzAmounts[i];
        }
        
        // Test ultra-optimized version
        uint256 gasUsed = gasleft();
        batchTransfer.batchTransferUltraOptimized{value: totalRequired}(fuzzRecipients, fuzzAmounts);
        gasUsed = gasUsed - gasleft();
        
        // Gas should scale roughly linearly with recipient count
        uint256 gasPerRecipient = gasUsed / recipientCount;
        console2.log("Recipients:", recipientCount, "Gas per recipient:", gasPerRecipient);
        
        // Adjust bounds based on actual measurements - smaller batches have higher per-recipient costs
        if (recipientCount <= 2) {
            assertLt(gasPerRecipient, 100000, "Small batch gas should be reasonable");
        } else {
            assertLt(gasPerRecipient, 60000, "Gas per recipient should be reasonable");
        }
        assertGt(gasPerRecipient, 1000, "Should use some gas per recipient");
    }
    
    // ===== HELPER FUNCTIONS =====
    
    function resetRecipientBalances() internal {
        for (uint256 i = 0; i < recipients.length; i++) {
            vm.deal(recipients[i], 0);
        }
    }
    
    // Test user statistics tracking
    function test_UserStats() public {
        uint256 totalRequired = 5.75 ether;
        batchTransfer.batchTransferStandard{value: totalRequired}(recipients, amounts);
        
        // Check alice's stats (first recipient)
        (uint256 received, uint256 transfers) = batchTransfer.getUserStats(recipients[0]);
        assertEq(received, 1 ether);
        assertEq(transfers, 1);
    }
    
    // Test emergency withdraw
    function test_EmergencyWithdraw() public {
        // Send some ETH to contract
        payable(address(batchTransfer)).transfer(1 ether);
        assertEq(address(batchTransfer).balance, 1 ether);
        
        // Emergency withdraw
        uint256 initialBalance = address(this).balance;
        batchTransfer.emergencyWithdraw();
        assertEq(address(this).balance, initialBalance + 1 ether);
        assertEq(address(batchTransfer).balance, 0);
    }
    
    // Handle receiving ETH for refunds
    receive() external payable {}
}
