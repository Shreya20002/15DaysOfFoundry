// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleBank {
    // State variables
    mapping(address => uint256) private balances;
    mapping(address => bool) public hasAccount;
    address[] private accountHolders;
    address public owner;
    uint256 public totalDeposits;
    bool private locked; // Reentrancy guard
    
    // Events
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);
    event Withdrawal(address indexed user, uint256 amount, uint256 newBalance);
    event AccountCreated(address indexed user);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier nonReentrant() {
        require(!locked, "Reentrancy detected");
        locked = true;
        _;
        locked = false;
    }
    
    modifier validAmount(uint256 amount) {
        require(amount > 0, "Amount must be greater than zero");
        _;
    }
    
    // Constructor
    constructor() {
        owner = msg.sender;
    }
    
    // Deposit function
    function deposit() external payable validAmount(msg.value) nonReentrant {
        // Create account if doesn't exist
        if (!hasAccount[msg.sender]) {
            hasAccount[msg.sender] = true;
            accountHolders.push(msg.sender);
            emit AccountCreated(msg.sender);
        }
        
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        
        emit Deposit(msg.sender, msg.value, balances[msg.sender]);
    }
    
    // Withdraw function
    function withdraw(uint256 amount) external validAmount(amount) nonReentrant {
        require(hasAccount[msg.sender], "Account does not exist");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        balances[msg.sender] -= amount;
        totalDeposits -= amount;
        
        // Transfer the funds
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");
        
        emit Withdrawal(msg.sender, amount, balances[msg.sender]);
    }
    
    // Withdraw all funds
    function withdrawAll() external nonReentrant {
        require(hasAccount[msg.sender], "Account does not exist");
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No funds to withdraw");
        
        balances[msg.sender] = 0;
        totalDeposits -= amount;
        
        // Transfer the funds
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");
        
        emit Withdrawal(msg.sender, amount, 0);
    }
    
    // View functions
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
    
    function getBalanceOf(address user) external view returns (uint256) {
        return balances[user];
    }
    
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    function getTotalAccountHolders() external view returns (uint256) {
        return accountHolders.length;
    }
    
    function getAccountHolders() external view onlyOwner returns (address[] memory) {
        return accountHolders;
    }
    
    function getUserAccountInfo(address user) external view returns (
        bool exists,
        uint256 balance
    ) {
        return (hasAccount[user], balances[user]);
    }
    
    // Emergency functions (only owner)
    function emergencyPause() external onlyOwner {
        locked = true;
    }
    
    function emergencyUnpause() external onlyOwner {
        locked = false;
    }
    
    // Allow contract to receive Ether
    receive() external payable {
        revert("Use deposit() function to send Ether");
    }
    
    fallback() external payable {
        revert("Function does not exist");
    }
}

