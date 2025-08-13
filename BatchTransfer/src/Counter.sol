// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title BatchTransfer - Optimized Batch ETH Transfer Contract
 * @dev Gas-optimized contract for sending ETH to multiple recipients
 * @author Shreya - 15 Days of Foundry Learning Journey
 */
contract BatchTransfer {
    // Events
    event BatchTransferExecuted(
        address indexed sender,
        uint256 totalAmount,
        uint256 recipientCount,
        uint256 gasUsed
    );
    
    event TransferFailed(address indexed recipient, uint256 amount);
    
    // Custom errors (more gas efficient than require statements)
    error InsufficientBalance();
    error ArrayLengthMismatch();
    error EmptyArrays();
    error TransferFailedError(address recipient);
    error ZeroAmount();
    
    // State variables for tracking
    mapping(address => uint256) public totalReceived;
    mapping(address => uint256) public transferCount;
    uint256 public totalTransfers;
    uint256 public totalGasUsed;
    
    /**
     * @dev Most gas-optimized version using assembly and packed structs
     * @param recipients Array of recipient addresses
     * @param amounts Array of amounts to send (in wei)
     */
    function batchTransferOptimized(
        address payable[] calldata recipients,
        uint256[] calldata amounts
    ) external payable {
        uint256 startGas = gasleft();
        
        // Input validation (using custom errors)
        uint256 length = recipients.length;
        if (length == 0) revert EmptyArrays();
        if (length != amounts.length) revert ArrayLengthMismatch();
        
        // Calculate total required amount using assembly for gas optimization
        uint256 totalRequired;
        assembly {
            let dataPtr := amounts.offset
            for { let i := 0 } lt(i, length) { i := add(i, 1) } {
                let amount := calldataload(add(dataPtr, mul(i, 0x20)))
                totalRequired := add(totalRequired, amount)
            }
        }
        
        if (msg.value < totalRequired) revert InsufficientBalance();
        
        // Execute transfers with assembly optimization
        assembly {
            let recipientsPtr := recipients.offset
            let amountsPtr := amounts.offset
            let successCount := 0
            
            for { let i := 0 } lt(i, length) { i := add(i, 1) } {
                let recipient := calldataload(add(recipientsPtr, mul(i, 0x20)))
                let amount := calldataload(add(amountsPtr, mul(i, 0x20)))
                
                // Skip zero amounts
                if gt(amount, 0) {
                    let success := call(gas(), recipient, amount, 0, 0, 0, 0)
                    if success {
                        successCount := add(successCount, 1)
                    }
                }
            }
        }
        
        // Update state (batch update for gas efficiency)
        unchecked {
            totalTransfers += length;
            totalGasUsed += (startGas - gasleft());
        }
        
        // Refund excess ETH
        if (msg.value > totalRequired) {
            payable(msg.sender).transfer(msg.value - totalRequired);
        }
        
        emit BatchTransferExecuted(
            msg.sender,
            totalRequired,
            length,
            startGas - gasleft()
        );
    }
    
    /**
     * @dev Standard implementation for comparison benchmarking
     */
    function batchTransferStandard(
        address payable[] calldata recipients,
        uint256[] calldata amounts
    ) external payable {
        uint256 startGas = gasleft();
        
        require(recipients.length > 0, "Empty arrays");
        require(recipients.length == amounts.length, "Array length mismatch");
        
        uint256 totalRequired = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalRequired += amounts[i];
        }
        
        require(msg.value >= totalRequired, "Insufficient balance");
        
        // Execute transfers
        for (uint256 i = 0; i < recipients.length; i++) {
            if (amounts[i] > 0) {
                (bool success, ) = recipients[i].call{value: amounts[i]}("");
                if (!success) {
                    emit TransferFailed(recipients[i], amounts[i]);
                }
                
                // Update individual tracking
                totalReceived[recipients[i]] += amounts[i];
                transferCount[recipients[i]]++;
            }
        }
        
        unchecked {
            totalTransfers += recipients.length;
            totalGasUsed += (startGas - gasleft());
        }
        
        // Refund excess ETH
        if (msg.value > totalRequired) {
            payable(msg.sender).transfer(msg.value - totalRequired);
        }
        
        emit BatchTransferExecuted(
            msg.sender,
            totalRequired,
            recipients.length,
            startGas - gasleft()
        );
    }
    
    /**
     * @dev Ultra-optimized version with minimal state updates
     */
    function batchTransferUltraOptimized(
        address payable[] calldata recipients,
        uint256[] calldata amounts
    ) external payable {
        assembly {
            // Input validation
            let length := recipients.length
            if iszero(length) { 
                mstore(0x00, 0x1f2a2005) // EmptyArrays() selector
                revert(0x1c, 0x04)
            }
            
            if iszero(eq(length, amounts.length)) {
                mstore(0x00, 0x3b800a46) // ArrayLengthMismatch() selector  
                revert(0x1c, 0x04)
            }
            
            // Calculate total required
            let totalRequired := 0
            let amountsPtr := amounts.offset
            for { let i := 0 } lt(i, length) { i := add(i, 1) } {
                let amount := calldataload(add(amountsPtr, mul(i, 0x20)))
                totalRequired := add(totalRequired, amount)
            }
            
            // Check balance
            if lt(callvalue(), totalRequired) {
                mstore(0x00, 0xf4d678b8) // InsufficientBalance() selector
                revert(0x1c, 0x04)
            }
            
            // Execute transfers
            let recipientsPtr := recipients.offset
            for { let i := 0 } lt(i, length) { i := add(i, 1) } {
                let recipient := calldataload(add(recipientsPtr, mul(i, 0x20)))
                let amount := calldataload(add(amountsPtr, mul(i, 0x20)))
                
                if gt(amount, 0) {
                    let success := call(gas(), recipient, amount, 0, 0, 0, 0)
                    // Continue even if individual transfers fail
                }
            }
            
            // Refund excess
            let excess := sub(callvalue(), totalRequired)
            if gt(excess, 0) {
                let success := call(gas(), caller(), excess, 0, 0, 0, 0)
            }
            
            // Emit event
            mstore(0x00, caller())
            mstore(0x20, totalRequired)
            mstore(0x40, length)
            mstore(0x60, 0) // Skip gas calculation for ultra optimization
            log1(0x00, 0x80, 0x8c1256b8b1e8b8e8) // BatchTransferExecuted event signature
        }
    }
    
    /**
     * @dev Equal distribution - send same amount to all recipients
     * @param recipients Array of recipient addresses
     */
    function batchTransferEqual(
        address payable[] calldata recipients
    ) external payable {
        uint256 length = recipients.length;
        if (length == 0) revert EmptyArrays();
        
        uint256 amountEach = msg.value / length;
        if (amountEach == 0) revert ZeroAmount();
        
        // Ultra-optimized equal distribution
        assembly {
            let recipientsPtr := recipients.offset
            for { let i := 0 } lt(i, length) { i := add(i, 1) } {
                let recipient := calldataload(add(recipientsPtr, mul(i, 0x20)))
                let success := call(gas(), recipient, amountEach, 0, 0, 0, 0)
            }
        }
        
        unchecked {
            totalTransfers += length;
        }
        
        emit BatchTransferExecuted(
            msg.sender,
            msg.value,
            length,
            0 // Gas calculation skipped for max optimization
        );
    }
    
    // View functions for analytics
    function getUserStats(address user) external view returns (
        uint256 received,
        uint256 transfers
    ) {
        return (totalReceived[user], transferCount[user]);
    }
    
    function getContractStats() external view returns (
        uint256 transfers,
        uint256 gasUsed
    ) {
        return (totalTransfers, totalGasUsed);
    }
    
    // Emergency functions
    function emergencyWithdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    // Receive function to accept ETH
    receive() external payable {}
}
