// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract TokenSwap {
    // State variables
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    address public owner;
    
    // Swap tracking
    mapping(address => uint256) public totalSwappedA;
    mapping(address => uint256) public totalSwappedB;
    uint256 public totalVolumeA;
    uint256 public totalVolumeB;
    
    // Events
    event SwapAtoB(address indexed user, uint256 amountA, uint256 amountB);
    event SwapBtoA(address indexed user, uint256 amountB, uint256 amountA);
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier validAmount(uint256 amount) {
        require(amount > 0, "Amount must be greater than zero");
        _;
    }
    
    // Constructor
    constructor(address _tokenA, address _tokenB) {
        require(_tokenA != address(0), "TokenA address cannot be zero");
        require(_tokenB != address(0), "TokenB address cannot be zero");
        require(_tokenA != _tokenB, "Tokens must be different");
        
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }
    
    // Swap TokenA for TokenB (1:1 ratio)
    function swapAtoB(uint256 amountA) external validAmount(amountA) {
        // Check if contract has enough TokenB
        uint256 contractBalanceB = tokenB.balanceOf(address(this));
        require(contractBalanceB >= amountA, "Insufficient TokenB in contract");
        
        // Transfer TokenA from user to contract
        require(
            tokenA.transferFrom(msg.sender, address(this), amountA),
            "Transfer of TokenA failed"
        );
        
        // Transfer TokenB from contract to user (1:1 ratio)
        require(
            tokenB.transfer(msg.sender, amountA),
            "Transfer of TokenB failed"
        );
        
        // Update tracking
        totalSwappedA[msg.sender] += amountA;
        totalVolumeA += amountA;
        
        emit SwapAtoB(msg.sender, amountA, amountA);
    }
    
    // Swap TokenB for TokenA (1:1 ratio)
    function swapBtoA(uint256 amountB) external validAmount(amountB) {
        // Check if contract has enough TokenA
        uint256 contractBalanceA = tokenA.balanceOf(address(this));
        require(contractBalanceA >= amountB, "Insufficient TokenA in contract");
        
        // Transfer TokenB from user to contract
        require(
            tokenB.transferFrom(msg.sender, address(this), amountB),
            "Transfer of TokenB failed"
        );
        
        // Transfer TokenA from contract to user (1:1 ratio)
        require(
            tokenA.transfer(msg.sender, amountB),
            "Transfer of TokenA failed"
        );
        
        // Update tracking
        totalSwappedB[msg.sender] += amountB;
        totalVolumeB += amountB;
        
        emit SwapBtoA(msg.sender, amountB, amountB);
    }
    
    // Add liquidity to the contract (owner only)
    function addLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        if (amountA > 0) {
            require(
                tokenA.transferFrom(msg.sender, address(this), amountA),
                "Transfer of TokenA failed"
            );
        }
        
        if (amountB > 0) {
            require(
                tokenB.transferFrom(msg.sender, address(this), amountB),
                "Transfer of TokenB failed"
            );
        }
        
        emit LiquidityAdded(msg.sender, amountA, amountB);
    }
    
    // Remove liquidity from the contract (owner only)
    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        if (amountA > 0) {
            uint256 contractBalanceA = tokenA.balanceOf(address(this));
            require(contractBalanceA >= amountA, "Insufficient TokenA in contract");
            
            require(
                tokenA.transfer(msg.sender, amountA),
                "Transfer of TokenA failed"
            );
        }
        
        if (amountB > 0) {
            uint256 contractBalanceB = tokenB.balanceOf(address(this));
            require(contractBalanceB >= amountB, "Insufficient TokenB in contract");
            
            require(
                tokenB.transfer(msg.sender, amountB),
                "Transfer of TokenB failed"
            );
        }
        
        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }
    
    // View functions
    function getContractBalances() external view returns (uint256 balanceA, uint256 balanceB) {
        balanceA = tokenA.balanceOf(address(this));
        balanceB = tokenB.balanceOf(address(this));
    }
    
    function getUserSwapHistory(address user) external view returns (uint256 swappedA, uint256 swappedB) {
        swappedA = totalSwappedA[user];
        swappedB = totalSwappedB[user];
    }
    
    function getTotalVolume() external view returns (uint256 volumeA, uint256 volumeB) {
        volumeA = totalVolumeA;
        volumeB = totalVolumeB;
    }
    
    // Calculate how much TokenB user would receive for given TokenA (1:1 ratio)
    function getAmountOut(bool isAtoB, uint256 amountIn) external view returns (uint256 amountOut) {
        require(amountIn > 0, "Amount must be greater than zero");
        
        if (isAtoB) {
            // Check if enough TokenB available
            uint256 contractBalanceB = tokenB.balanceOf(address(this));
            require(contractBalanceB >= amountIn, "Insufficient TokenB in contract");
            amountOut = amountIn; // 1:1 ratio
        } else {
            // Check if enough TokenA available
            uint256 contractBalanceA = tokenA.balanceOf(address(this));
            require(contractBalanceA >= amountIn, "Insufficient TokenA in contract");
            amountOut = amountIn; // 1:1 ratio
        }
    }
}
