// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TokenSwap} from "../src/TokenSwap.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract TokenSwapTest is Test {
    TokenSwap public swap;
    MockERC20 public tokenA;
    MockERC20 public tokenB;
    
    address public owner;
    address public alice;
    address public bob;
    address public charlie;
    
    // Initial supplies
    uint256 constant INITIAL_SUPPLY = 1000000 * 1e18;
    uint256 constant LIQUIDITY_AMOUNT = 100000 * 1e18;
    
    // Events to test
    event SwapAtoB(address indexed user, uint256 amountA, uint256 amountB);
    event SwapBtoA(address indexed user, uint256 amountB, uint256 amountA);
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);
    
    function setUp() public {
        // Setup test accounts
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");
        
        // Deploy tokens
        tokenA = new MockERC20("TokenA", "TKNA", 18);
        tokenB = new MockERC20("TokenB", "TKNB", 18);
        
        // Deploy swap contract
        swap = new TokenSwap(address(tokenA), address(tokenB));
        
        // Mint initial tokens
        tokenA.mint(owner, INITIAL_SUPPLY);
        tokenB.mint(owner, INITIAL_SUPPLY);
        
        // Add initial liquidity
        tokenA.approve(address(swap), LIQUIDITY_AMOUNT);
        tokenB.approve(address(swap), LIQUIDITY_AMOUNT);
        swap.addLiquidity(LIQUIDITY_AMOUNT, LIQUIDITY_AMOUNT);
        
        // Give users some tokens
        tokenA.mint(alice, 10000 * 1e18);
        tokenB.mint(alice, 10000 * 1e18);
        tokenA.mint(bob, 5000 * 1e18);
        tokenB.mint(bob, 5000 * 1e18);
        tokenA.mint(charlie, 2000 * 1e18);
        tokenB.mint(charlie, 2000 * 1e18);
    }
    
    // ============ BASIC FUNCTIONALITY TESTS ============
    
    function test_InitialState() public {
        assertEq(swap.owner(), owner);
        assertEq(address(swap.tokenA()), address(tokenA));
        assertEq(address(swap.tokenB()), address(tokenB));
        
        (uint256 balanceA, uint256 balanceB) = swap.getContractBalances();
        assertEq(balanceA, LIQUIDITY_AMOUNT);
        assertEq(balanceB, LIQUIDITY_AMOUNT);
        
        (uint256 volumeA, uint256 volumeB) = swap.getTotalVolume();
        assertEq(volumeA, 0);
        assertEq(volumeB, 0);
    }
    
    function test_SwapAtoB() public {
        uint256 swapAmount = 1000 * 1e18;
        
        // Alice approves and swaps
        vm.startPrank(alice);
        tokenA.approve(address(swap), swapAmount);
        
        uint256 aliceBalanceA_before = tokenA.balanceOf(alice);
        uint256 aliceBalanceB_before = tokenB.balanceOf(alice);
        
        vm.expectEmit(true, false, false, true);
        emit SwapAtoB(alice, swapAmount, swapAmount);
        
        swap.swapAtoB(swapAmount);
        vm.stopPrank();
        
        // Check balances
        assertEq(tokenA.balanceOf(alice), aliceBalanceA_before - swapAmount);
        assertEq(tokenB.balanceOf(alice), aliceBalanceB_before + swapAmount);
        
        // Check tracking
        (uint256 swappedA, uint256 swappedB) = swap.getUserSwapHistory(alice);
        assertEq(swappedA, swapAmount);
        assertEq(swappedB, 0);
        
        (uint256 volumeA, uint256 volumeB) = swap.getTotalVolume();
        assertEq(volumeA, swapAmount);
        assertEq(volumeB, 0);
    }
    
    function test_SwapBtoA() public {
        uint256 swapAmount = 1500 * 1e18;
        
        // Bob approves and swaps
        vm.startPrank(bob);
        tokenB.approve(address(swap), swapAmount);
        
        uint256 bobBalanceA_before = tokenA.balanceOf(bob);
        uint256 bobBalanceB_before = tokenB.balanceOf(bob);
        
        vm.expectEmit(true, false, false, true);
        emit SwapBtoA(bob, swapAmount, swapAmount);
        
        swap.swapBtoA(swapAmount);
        vm.stopPrank();
        
        // Check balances
        assertEq(tokenA.balanceOf(bob), bobBalanceA_before + swapAmount);
        assertEq(tokenB.balanceOf(bob), bobBalanceB_before - swapAmount);
        
        // Check tracking
        (uint256 swappedA, uint256 swappedB) = swap.getUserSwapHistory(bob);
        assertEq(swappedA, 0);
        assertEq(swappedB, swapAmount);
    }
    
    function test_GetAmountOut() public {
        uint256 amountIn = 500 * 1e18;
        
        // Test A to B
        uint256 amountOutAtoB = swap.getAmountOut(true, amountIn);
        assertEq(amountOutAtoB, amountIn); // 1:1 ratio
        
        // Test B to A
        uint256 amountOutBtoA = swap.getAmountOut(false, amountIn);
        assertEq(amountOutBtoA, amountIn); // 1:1 ratio
    }
    
    // ============ LIQUIDITY MANAGEMENT TESTS ============
    
    function test_AddLiquidity() public {
        uint256 addAmountA = 5000 * 1e18;
        uint256 addAmountB = 3000 * 1e18;
        
        tokenA.approve(address(swap), addAmountA);
        tokenB.approve(address(swap), addAmountB);
        
        (uint256 beforeA, uint256 beforeB) = swap.getContractBalances();
        
        vm.expectEmit(true, false, false, true);
        emit LiquidityAdded(owner, addAmountA, addAmountB);
        
        swap.addLiquidity(addAmountA, addAmountB);
        
        (uint256 afterA, uint256 afterB) = swap.getContractBalances();
        assertEq(afterA, beforeA + addAmountA);
        assertEq(afterB, beforeB + addAmountB);
    }
    
    function test_RemoveLiquidity() public {
        uint256 removeAmountA = 2000 * 1e18;
        uint256 removeAmountB = 3000 * 1e18;
        
        (uint256 beforeA, uint256 beforeB) = swap.getContractBalances();
        uint256 ownerBalanceA_before = tokenA.balanceOf(owner);
        uint256 ownerBalanceB_before = tokenB.balanceOf(owner);
        
        vm.expectEmit(true, false, false, true);
        emit LiquidityRemoved(owner, removeAmountA, removeAmountB);
        
        swap.removeLiquidity(removeAmountA, removeAmountB);
        
        (uint256 afterA, uint256 afterB) = swap.getContractBalances();
        assertEq(afterA, beforeA - removeAmountA);
        assertEq(afterB, beforeB - removeAmountB);
        
        assertEq(tokenA.balanceOf(owner), ownerBalanceA_before + removeAmountA);
        assertEq(tokenB.balanceOf(owner), ownerBalanceB_before + removeAmountB);
    }
    
    // ============ ERROR HANDLING TESTS ============
    
    function test_RevertZeroAddress() public {
        vm.expectRevert("TokenA address cannot be zero");
        new TokenSwap(address(0), address(tokenB));
        
        vm.expectRevert("TokenB address cannot be zero");
        new TokenSwap(address(tokenA), address(0));
    }
    
    function test_RevertSameTokens() public {
        vm.expectRevert("Tokens must be different");
        new TokenSwap(address(tokenA), address(tokenA));
    }
    
    function test_RevertZeroAmount() public {
        vm.startPrank(alice);
        vm.expectRevert("Amount must be greater than zero");
        swap.swapAtoB(0);
        
        vm.expectRevert("Amount must be greater than zero");
        swap.swapBtoA(0);
        vm.stopPrank();
    }
    
    function test_RevertInsufficientLiquidity() public {
        uint256 excessiveAmount = LIQUIDITY_AMOUNT + 1;
        
        vm.startPrank(alice);
        tokenA.approve(address(swap), excessiveAmount);
        vm.expectRevert("Insufficient TokenB in contract");
        swap.swapAtoB(excessiveAmount);
        
        tokenB.approve(address(swap), excessiveAmount);
        vm.expectRevert("Insufficient TokenA in contract");
        swap.swapBtoA(excessiveAmount);
        vm.stopPrank();
    }
    
    function test_RevertInsufficientAllowance() public {
        uint256 swapAmount = 1000 * 1e18;
        
        vm.startPrank(alice);
        // Don't approve tokens
        vm.expectRevert();
        swap.swapAtoB(swapAmount);
        
        vm.expectRevert();
        swap.swapBtoA(swapAmount);
        vm.stopPrank();
    }
    
    function test_RevertOnlyOwner() public {
        vm.startPrank(alice);
        vm.expectRevert("Only owner can call this function");
        swap.addLiquidity(1000, 1000);
        
        vm.expectRevert("Only owner can call this function");
        swap.removeLiquidity(1000, 1000);
        vm.stopPrank();
    }
    
    // ============ COMPREHENSIVE FUZZ TESTS ============
    
    function testFuzz_SwapAtoB(uint256 amount) public {
        // Bound the amount to reasonable values (max liquidity available and alice's balance)
        uint256 maxAmount = tokenA.balanceOf(alice);
        amount = bound(amount, 1, maxAmount < LIQUIDITY_AMOUNT ? maxAmount : LIQUIDITY_AMOUNT);
        
        vm.startPrank(alice);
        tokenA.approve(address(swap), amount);
        
        uint256 aliceBalanceA_before = tokenA.balanceOf(alice);
        uint256 aliceBalanceB_before = tokenB.balanceOf(alice);
        uint256 contractBalanceA_before = tokenA.balanceOf(address(swap));
        uint256 contractBalanceB_before = tokenB.balanceOf(address(swap));
        
        swap.swapAtoB(amount);
        vm.stopPrank();
        
        // Verify 1:1 swap ratio
        assertEq(tokenA.balanceOf(alice), aliceBalanceA_before - amount);
        assertEq(tokenB.balanceOf(alice), aliceBalanceB_before + amount);
        
        // Verify contract balances
        assertEq(tokenA.balanceOf(address(swap)), contractBalanceA_before + amount);
        assertEq(tokenB.balanceOf(address(swap)), contractBalanceB_before - amount);
        
        // Verify tracking
        (uint256 swappedA, ) = swap.getUserSwapHistory(alice);
        assertGe(swappedA, amount);
    }
    
    function testFuzz_SwapBtoA(uint256 amount) public {
        // Bound the amount to reasonable values (max liquidity available and bob's balance)
        uint256 maxAmount = tokenB.balanceOf(bob);
        amount = bound(amount, 1, maxAmount < LIQUIDITY_AMOUNT ? maxAmount : LIQUIDITY_AMOUNT);
        
        vm.startPrank(bob);
        tokenB.approve(address(swap), amount);
        
        uint256 bobBalanceA_before = tokenA.balanceOf(bob);
        uint256 bobBalanceB_before = tokenB.balanceOf(bob);
        uint256 contractBalanceA_before = tokenA.balanceOf(address(swap));
        uint256 contractBalanceB_before = tokenB.balanceOf(address(swap));
        
        swap.swapBtoA(amount);
        vm.stopPrank();
        
        // Verify 1:1 swap ratio
        assertEq(tokenA.balanceOf(bob), bobBalanceA_before + amount);
        assertEq(tokenB.balanceOf(bob), bobBalanceB_before - amount);
        
        // Verify contract balances
        assertEq(tokenA.balanceOf(address(swap)), contractBalanceA_before - amount);
        assertEq(tokenB.balanceOf(address(swap)), contractBalanceB_before + amount);
        
        // Verify tracking
        (, uint256 swappedB) = swap.getUserSwapHistory(bob);
        assertGe(swappedB, amount);
    }
    
    function testFuzz_BidirectionalSwap(uint256 amountA, uint256 amountB) public {
        // Bound amounts to ensure liquidity is available and users have sufficient tokens
        uint256 charlieBalanceA = tokenA.balanceOf(charlie);
        uint256 charlieBalanceB = tokenB.balanceOf(charlie);
        
        amountA = bound(amountA, 1, charlieBalanceA < LIQUIDITY_AMOUNT / 2 ? charlieBalanceA : LIQUIDITY_AMOUNT / 2);
        
        vm.startPrank(charlie);
        
        // Swap A to B first
        tokenA.approve(address(swap), amountA);
        uint256 charlieBalanceA_before = tokenA.balanceOf(charlie);
        uint256 charlieBalanceB_before = tokenB.balanceOf(charlie);
        
        swap.swapAtoB(amountA);
        
        assertEq(tokenA.balanceOf(charlie), charlieBalanceA_before - amountA);
        assertEq(tokenB.balanceOf(charlie), charlieBalanceB_before + amountA);
        
        // Update charlie's balance after first swap
        uint256 newCharlieBalanceB = tokenB.balanceOf(charlie);
        amountB = bound(amountB, 1, newCharlieBalanceB < LIQUIDITY_AMOUNT / 2 ? newCharlieBalanceB : LIQUIDITY_AMOUNT / 2);
        
        // Now swap B to A
        tokenB.approve(address(swap), amountB);
        uint256 charlieBalanceA_mid = tokenA.balanceOf(charlie);
        uint256 charlieBalanceB_mid = tokenB.balanceOf(charlie);
        
        swap.swapBtoA(amountB);
        
        assertEq(tokenA.balanceOf(charlie), charlieBalanceA_mid + amountB);
        assertEq(tokenB.balanceOf(charlie), charlieBalanceB_mid - amountB);
        
        vm.stopPrank();
        
        // Verify tracking
        (uint256 swappedA, uint256 swappedB) = swap.getUserSwapHistory(charlie);
        assertEq(swappedA, amountA);
        assertEq(swappedB, amountB);
    }
    
    function testFuzz_MultipleUsersSwap(uint256 aliceAmount, uint256 bobAmount) public {
        // Bound amounts to user balances and available liquidity
        uint256 aliceMaxA = tokenA.balanceOf(alice);
        uint256 bobMaxB = tokenB.balanceOf(bob);
        
        aliceAmount = bound(aliceAmount, 1, aliceMaxA < LIQUIDITY_AMOUNT / 3 ? aliceMaxA : LIQUIDITY_AMOUNT / 3);
        bobAmount = bound(bobAmount, 1, bobMaxB < LIQUIDITY_AMOUNT / 3 ? bobMaxB : LIQUIDITY_AMOUNT / 3);
        
        // Alice swaps A to B
        vm.startPrank(alice);
        tokenA.approve(address(swap), aliceAmount);
        swap.swapAtoB(aliceAmount);
        vm.stopPrank();
        
        // Bob swaps B to A
        vm.startPrank(bob);
        tokenB.approve(address(swap), bobAmount);
        swap.swapBtoA(bobAmount);
        vm.stopPrank();
        
        // Verify individual tracking
        (uint256 aliceSwappedA, uint256 aliceSwappedB) = swap.getUserSwapHistory(alice);
        (uint256 bobSwappedA, uint256 bobSwappedB) = swap.getUserSwapHistory(bob);
        
        assertEq(aliceSwappedA, aliceAmount);
        assertEq(aliceSwappedB, 0);
        assertEq(bobSwappedA, 0);
        assertEq(bobSwappedB, bobAmount);
        
        // Verify total volume
        (uint256 volumeA, uint256 volumeB) = swap.getTotalVolume();
        assertEq(volumeA, aliceAmount);
        assertEq(volumeB, bobAmount);
    }
    
    function testFuzz_LiquidityOperations(uint256 addA, uint256 addB, uint256 removeA, uint256 removeB) public {
        // Bound amounts
        addA = bound(addA, 0, 50000 * 1e18);
        addB = bound(addB, 0, 50000 * 1e18);
        
        // Add liquidity
        if (addA > 0) tokenA.approve(address(swap), addA);
        if (addB > 0) tokenB.approve(address(swap), addB);
        
        (uint256 beforeA, uint256 beforeB) = swap.getContractBalances();
        swap.addLiquidity(addA, addB);
        (uint256 afterAddA, uint256 afterAddB) = swap.getContractBalances();
        
        assertEq(afterAddA, beforeA + addA);
        assertEq(afterAddB, beforeB + addB);
        
        // Remove liquidity (ensure we don't remove more than available)
        removeA = bound(removeA, 0, afterAddA);
        removeB = bound(removeB, 0, afterAddB);
        
        swap.removeLiquidity(removeA, removeB);
        (uint256 afterRemoveA, uint256 afterRemoveB) = swap.getContractBalances();
        
        assertEq(afterRemoveA, afterAddA - removeA);
        assertEq(afterRemoveB, afterAddB - removeB);
    }
    
    function testFuzz_GetAmountOut(uint256 amount) public {
        (uint256 balanceA, uint256 balanceB) = swap.getContractBalances();
        
        // Test A to B
        if (amount > 0 && amount <= balanceB) {
            uint256 amountOut = swap.getAmountOut(true, amount);
            assertEq(amountOut, amount); // 1:1 ratio
        }
        
        // Test B to A
        if (amount > 0 && amount <= balanceA) {
            uint256 amountOut = swap.getAmountOut(false, amount);
            assertEq(amountOut, amount); // 1:1 ratio
        }
    }
    
    // ============ INVARIANT TESTS ============
    
    function testInvariant_TotalSupplyConservation() public {
        uint256 swapAmount = 1000 * 1e18;
        
        // Get initial total supplies in circulation
        uint256 totalA_initial = tokenA.totalSupply();
        uint256 totalB_initial = tokenB.totalSupply();
        
        // Perform swap
        vm.startPrank(alice);
        tokenA.approve(address(swap), swapAmount);
        swap.swapAtoB(swapAmount);
        vm.stopPrank();
        
        // Total supply should remain the same
        assertEq(tokenA.totalSupply(), totalA_initial);
        assertEq(tokenB.totalSupply(), totalB_initial);
    }
    
    function testInvariant_BalanceConservation() public {
        uint256 swapAmount = 2000 * 1e18;
        
        // Get initial balances
        uint256 aliceA_initial = tokenA.balanceOf(alice);
        uint256 aliceB_initial = tokenB.balanceOf(alice);
        uint256 contractA_initial = tokenA.balanceOf(address(swap));
        uint256 contractB_initial = tokenB.balanceOf(address(swap));
        
        // Total tokens in system
        uint256 totalA_system = aliceA_initial + contractA_initial;
        uint256 totalB_system = aliceB_initial + contractB_initial;
        
        // Perform swap
        vm.startPrank(alice);
        tokenA.approve(address(swap), swapAmount);
        swap.swapAtoB(swapAmount);
        vm.stopPrank();
        
        // Check that total tokens in system remain the same
        uint256 aliceA_final = tokenA.balanceOf(alice);
        uint256 aliceB_final = tokenB.balanceOf(alice);
        uint256 contractA_final = tokenA.balanceOf(address(swap));
        uint256 contractB_final = tokenB.balanceOf(address(swap));
        
        assertEq(aliceA_final + contractA_final, totalA_system);
        assertEq(aliceB_final + contractB_final, totalB_system);
    }
}
