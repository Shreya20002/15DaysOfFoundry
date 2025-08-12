// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TokenSwap} from "../src/TokenSwap.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract TokenSwapScript is Script {
    TokenSwap public swap;
    MockERC20 public tokenA;
    MockERC20 public tokenB;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy mock tokens for demonstration
        tokenA = new MockERC20("TokenA", "TKNA", 18);
        tokenB = new MockERC20("TokenB", "TKNB", 18);
        
        console.log("TokenA deployed to:", address(tokenA));
        console.log("TokenB deployed to:", address(tokenB));

        // Deploy the TokenSwap contract
        swap = new TokenSwap(address(tokenA), address(tokenB));
        
        console.log("TokenSwap deployed to:", address(swap));
        console.log("Owner:", swap.owner());
        
        // Mint some initial tokens to the deployer
        uint256 initialAmount = 1000000 * 1e18; // 1M tokens
        tokenA.mint(msg.sender, initialAmount);
        tokenB.mint(msg.sender, initialAmount);
        
        console.log("Minted", initialAmount / 1e18, "tokens each to deployer");
        
        // Add initial liquidity
        uint256 liquidityAmount = 100000 * 1e18; // 100K tokens each
        tokenA.approve(address(swap), liquidityAmount);
        tokenB.approve(address(swap), liquidityAmount);
        swap.addLiquidity(liquidityAmount, liquidityAmount);
        
        console.log("Added initial liquidity:", liquidityAmount / 1e18, "tokens each");
        
        (uint256 balanceA, uint256 balanceB) = swap.getContractBalances();
        console.log("Contract TokenA balance:", balanceA / 1e18);
        console.log("Contract TokenB balance:", balanceB / 1e18);

        vm.stopBroadcast();
    }
}
