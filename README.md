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

## Technologies Used
- **Foundry**: Smart contract development framework
- **Solidity**: Smart contract programming language
- **Cast**: Command-line tool for Ethereum interaction
- **Anvil**: Local Ethereum node for testing

## Learning Goals
- Master Foundry development workflow
- Understand smart contract testing patterns
- Practice Cast and Anvil for contract interaction
- Build progressively complex DeFi applications

## Progress
- [x] Day 1: Basic Counter Contract
- [x] Day 2: Interactive Greeting Contract with Cast/Anvil
- [x] Day 3: SimpleBank with Security Features and Comprehensive Tests
- [x] Day 4: TokenSwap with 1:1 Ratio and Extensive Fuzz Testing
- [ ] Day 5-15: More complex projects coming soon...

---
Built with ❤️ by Shreya during my Foundry learning journey
