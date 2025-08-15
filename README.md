# 15 Days of Foundry

A learning journey through Foundry smart contract development, featuring practical examples and hands-on projects.

## Projects

### 1. Counter (`/Counter`)
A simple counter contract demonstrating basic Foundry project structure:
- Basic state management
- Function calls and testing
- Foundry project setup

### 2. Greeting (`/Greeting`) 
An interactive greeting contract showcasing Cast and Anvil in action:
- String storage and manipulation
- Event emission and tracking
- Real-time interaction with Cast commands
- Local blockchain testing with Anvil

### 3. SimpleBank (`/SimpleBank`) 
A secure banking contract with comprehensive features:
- Deposit and withdrawal functionality
- Multi-user account management
- Reentrancy protection and security measures
- Owner controls and emergency functions
- Comprehensive test suite with edge cases
- Fuzzing and stress tests

### 4. TokenSwap (`/TokenSwap`)
A 1:1 token swap contract with extensive fuzz testing:
- Perfect 1:1 token exchange ratio (A ↔ B)
- Bidirectional swapping capabilities
- Reentrancy protection and security measures
- Liquidity management by owner
- Comprehensive fuzz testing (260+ runs per test)
- MockERC20 tokens for testing
- Event emission for complete audit trail
- User swap tracking and volume statistics

### 5. BatchTransfer (`/BatchTransfer`)
Gas-optimized batch ETH transfer contract with comprehensive benchmarking:
- **84% gas savings** achieved through multiple optimization levels
- 4 implementation variants: Standard, Optimized, Ultra-Optimized, Equal Distribution
- Assembly-level optimizations for maximum efficiency
- Custom errors for gas savings (50+ gas per validation)
- Equal distribution specialist for airdrops and uniform payments
- Comprehensive gas benchmarking with Foundry tools
- Extensive fuzz testing (259 runs) for robustness validation
- Real-world scalability: 36K gas per recipient at optimal batch sizes
- Production security features and emergency controls

## Getting Started

### Prerequisites
- [Rust](https://rustup.rs/)
- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation
```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Clone this repository
git clone https://github.com/Shreya20002/15DaysOfFoundry.git
cd 15DaysOfFoundry
```

### Running Projects

#### Counter Project
```bash
cd Counter
forge build
forge test
```

#### SimpleBank Project
```bash
cd SimpleBank
forge build
forge test

# Deploy to local network
anvil

# In another terminal
forge script script/SimpleBank.s.sol:SimpleBankScript --rpc-url http://127.0.0.1:8545 --private-key --broadcast

# Interact with the deployed contract
cast send <CONTRACT_ADDRESS> "deposit()" --value 5ether --rpc-url http://127.0.0.1:8545 --private-key 

cast call <CONTRACT_ADDRESS> "getBalance()" --rpc-url http://127.0.0.1:8545 --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```

#### TokenSwap Project
```bash
cd TokenSwap
forge build
forge test

# Run comprehensive fuzz tests
forge test --fuzz-runs 260

# Deploy to local network
anvil

# In another terminal
forge script script/TokenSwap.s.sol:TokenSwapScript --rpc-url http://127.0.0.1:8545 --private-key --broadcast

# Interact with deployed contracts
# Get contract balances
cast call <TOKENSWAP_ADDRESS> "getContractBalances()" --rpc-url http://127.0.0.1:8545

# Swap TokenA for TokenB (first mint/approve tokens)
cast send <TOKENA_ADDRESS> "mint(address,uint256)" <YOUR_ADDRESS> 1000000000000000000000 --rpc-url http://127.0.0.1:8545 --private-key <YOUR_KEY>
cast send <TOKENA_ADDRESS> "approve(address,uint256)" <TOKENSWAP_ADDRESS> 1000000000000000000000 --rpc-url http://127.0.0.1:8545 --private-key <YOUR_KEY>
cast send <TOKENSWAP_ADDRESS> "swapAtoB(uint256)" 1000000000000000000000 --rpc-url http://127.0.0.1:8545 --private-key <YOUR_KEY>
```

#### BatchTransfer Project
```bash
cd BatchTransfer
forge build
forge test

# Run comprehensive gas benchmarking
forge test --gas-report -vv

# Run specific gas benchmark tests
forge test --match-test "test_GasBenchmark"

# Run fuzz tests for gas efficiency
forge test --match-test "testFuzz_GasEfficiency" --fuzz-runs 259

# Deploy to local network
anvil

# In another terminal
forge script script/Counter.s.sol:BatchTransferScript --rpc-url http://127.0.0.1:8545 --private-key --broadcast

# Batch transfer to multiple recipients (Ultra-Optimized)
cast send <CONTRACT_ADDRESS> "batchTransferUltraOptimized(address[],uint256[])" "[0x70997970C51812dc3A010C7d01b50e0d17dc79C8,0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC]" "[1000000000000000000,2000000000000000000]" --value 3ether --rpc-url http://127.0.0.1:8545 --private-key <YOUR_KEY>

# Equal distribution example
cast send <CONTRACT_ADDRESS> "batchTransferEqual(address[])" "[0x70997970C51812dc3A010C7d01b50e0d17dc79C8,0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC,0x90F79bf6EB2c4f870365E785982E1f101E93b906]" --value 3ether --rpc-url http://127.0.0.1:8545 --private-key <YOUR_KEY>

# Check contract statistics
cast call <CONTRACT_ADDRESS> "getContractStats()" --rpc-url http://127.0.0.1:8545
```

## Technologies Used
- **Foundry**: Smart contract development framework
- **Solidity**: Smart contract programming language  
- **Cast**: Command-line tool for Ethereum interaction
- **Anvil**: Local Ethereum node for testing
- **Assembly**: Low-level EVM optimizations
- **Fuzz Testing**: Property-based randomized testing

## Learning Goals & Achievements

### Days 1-5 Completed ✅
- ✅ Master Foundry development workflow
- ✅ Understand smart contract testing patterns  
- ✅ Practice Cast and Anvil for contract interaction
- ✅ Implement security best practices (reentrancy protection)
- ✅ Advanced fuzz testing with 260+ runs per function
- ✅ Gas optimization techniques and assembly programming
- ✅ Foundry gas profiling and benchmarking tools
- ✅ Production-ready error handling and custom errors
- ✅ Multi-contract deployment and interaction patterns

### Advanced Skills Mastered
- **Gas Optimization**: 84% reduction through assembly optimizations
- **Security Patterns**: Reentrancy guards, input validation, emergency controls  
- **Testing Strategies**: Unit, integration, fuzz, and gas benchmarking tests
- **Code Quality**: Custom errors, comprehensive documentation, event logging
- **Performance Analysis**: Detailed gas profiling and scalability testing

## Progress Tracker

| Day | Project | Focus Area | Status | Key Achievement |
|-----|---------|------------|--------|-----------------|
| 1 | Counter | Foundry Basics | ✅ Complete | Project setup mastery |
| 2 | Greeting | Cast & Anvil | ✅ Complete | CLI interaction skills |
| 3 | SimpleBank | Security & Testing | ✅ Complete | Reentrancy protection |
| 4 | TokenSwap | Fuzz Testing | ✅ Complete | 260+ fuzz test runs |
| 5 | BatchTransfer | Gas Optimization | ✅ Complete | 84% gas savings |
| 6 | Auction | Cheatcodes |✅ Complete |

---

**Current Status**: 5/15 Days Complete (33% Progress)  
**Next Milestone**: Day 6 - Advanced DeFi Patterns
- Build progressively complex DeFi applications

## Progress
- [x] Day 1: Basic Counter Contract
- [x] Day 2: Interactive Greeting Contract with Cast/Anvil
- [x] Day 3: SimpleBank with Security Features and Comprehensive Tests
- [x] Day 4: TokenSwap with 1:1 Ratio and Extensive Fuzz Testing
- [x] Day 5: BatchTransfer with Gas Optimization and 84% Savings
- [x] Day 6: Auction Contract with cheatcodes testig 
- [ ] Day 7-15: More complex projects coming soon...

---
Built with ❤️ by Shreya during my Foundry learning journey
