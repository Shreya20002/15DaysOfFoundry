// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {AaveBorrow} from "../src/AaveBorrow.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AaveBorrowTest is Test {
    AaveBorrow public aaveBorrow;
    address constant WHALE = 0x2fEb1512183545f48f6b9C5b4EbfCaF49CfCa6F3;
    
    function setUp() public {
        // Fork mainnet
        vm.createSelectFork("mainnet");
        
        aaveBorrow = new AaveBorrow();
        
        // Impersonate whale account
        vm.startPrank(WHALE);
        
        // Transfer WETH to our contract
        IERC20(aaveBorrow.WETH()).transfer(
            address(aaveBorrow),
            10 ether
        );
        
        vm.stopPrank();
    }

    function testSupplyAndBorrow() public {
        // Supply WETH as collateral
        aaveBorrow.supplyCollateral(1 ether);
        
        // Borrow USDC
        uint256 borrowAmount = 100 * 1e6; // 100 USDC
        aaveBorrow.borrowUsdc(borrowAmount);
        
        // Verify USDC balance
        uint256 usdcBalance = IERC20(aaveBorrow.USDC()).balanceOf(address(aaveBorrow));
        assertEq(usdcBalance, borrowAmount);
    }
}