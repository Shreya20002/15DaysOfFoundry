// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {BatchTransfer} from "../src/Counter.sol";

/**
 * @title BatchTransfer Deployment Script
 * @dev Deploy and demonstrate gas-optimized batch transfer contract
 */
contract BatchTransferScript is Script {
    BatchTransfer public batchTransfer;
    
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        
        // Deploy the contract
        batchTransfer = new BatchTransfer();
        console2.log("BatchTransfer deployed at:", address(batchTransfer));
        
        // Demonstrate usage with sample data
        demonstrateBatchTransfer();
        
        vm.stopBroadcast();
    }
    
    function demonstrateBatchTransfer() internal {
        console2.log("\n=== Demonstrating BatchTransfer Functionality ===");
        
        // Create sample recipients
        address payable[] memory recipients = new address payable[](3);
        recipients[0] = payable(0x742C2a3AF2E3f2E26B4C0B4C6F8f6F6CF6F6F6F6);
        recipients[1] = payable(0x853D3B4E3e4D4E37c7c7C7c7c7c7c7C7c7C7C7c7);
        recipients[2] = payable(0x964e4d5E5e5e5E48d8d8D8D8d8D8d8d8D8d8d8D8);
        
        // Create sample amounts
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 0.1 ether;
        amounts[1] = 0.2 ether;
        amounts[2] = 0.15 ether;
        
        uint256 totalRequired = 0.45 ether;
        
        console2.log("Recipients:");
        for (uint256 i = 0; i < recipients.length; i++) {
            console2.log("  ", recipients[i], "->", amounts[i]);
        }
        
        console2.log("Total required:", totalRequired);
        
        // Execute optimized batch transfer
        try batchTransfer.batchTransferOptimized{value: totalRequired}(recipients, amounts) {
            console2.log("SUCCESS: Optimized batch transfer successful!");
        } catch {
            console2.log("ERROR: Optimized batch transfer failed");
        }
        
        // Demonstrate equal distribution
        console2.log("\n=== Demonstrating Equal Distribution ===");
        try batchTransfer.batchTransferEqual{value: 0.3 ether}(recipients) {
            console2.log("SUCCESS: Equal distribution successful! (0.1 ETH each)");
        } catch {
            console2.log("ERROR: Equal distribution failed");
        }
        
        // Display final stats
        (uint256 totalTransfers, uint256 totalGasUsed) = batchTransfer.getContractStats();
        console2.log("\nContract Stats:");
        console2.log("  Total transfers:", totalTransfers);
        console2.log("  Total gas used:", totalGasUsed);
    }
    
    // Additional function for gas profiling demonstration
    function profileGasUsage() external {
        console2.log("\n=== Gas Usage Profiling ===");
        
        // Deploy fresh contract for clean profiling
        BatchTransfer profiler = new BatchTransfer();
        
        // Test data
        address payable[] memory recipients = new address payable[](5);
        uint256[] memory amounts = new uint256[](5);
        uint256 totalRequired = 0;
        
        for (uint256 i = 0; i < 5; i++) {
            recipients[i] = payable(address(uint160(0x1000 + i)));
            amounts[i] = (i + 1) * 0.1 ether;
            totalRequired += amounts[i];
        }
        
        // Profile different implementations
        console2.log("\nProfiling 5 recipients with varying amounts:");
        
        uint256 gasStandard = gasleft();
        profiler.batchTransferStandard{value: totalRequired}(recipients, amounts);
        gasStandard = gasStandard - gasleft();
        
        uint256 gasOptimized = gasleft();
        profiler.batchTransferOptimized{value: totalRequired}(recipients, amounts);
        gasOptimized = gasOptimized - gasleft();
        
        uint256 gasUltra = gasleft();
        profiler.batchTransferUltraOptimized{value: totalRequired}(recipients, amounts);
        gasUltra = gasUltra - gasleft();
        
        console2.log("Standard:     ", gasStandard, "gas");
        console2.log("Optimized:    ", gasOptimized, "gas");
        console2.log("Ultra:        ", gasUltra, "gas");
        console2.log("Savings (Opt):", gasStandard - gasOptimized, "gas");
        console2.log("Savings (Ultra):", gasStandard - gasUltra, "gas");
    }
}
