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
forge script script/SimpleBank.s.sol:SimpleBankScript --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

# Interact with the deployed contract
cast send <CONTRACT_ADDRESS> "deposit()" --value 5ether --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

cast call <CONTRACT_ADDRESS> "getBalance()" --rpc-url http://127.0.0.1:8545 --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
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
- [ ] Day 4-15: More complex projects coming soon...

---
Built with ❤️ by Shreya during my Foundry learning journey
