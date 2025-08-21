// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AaveBorrow {
    address public constant POOL = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function supplyCollateral(uint256 amount) external {
        IERC20(WETH).approve(POOL, amount);
        IPool(POOL).supply(WETH, amount, address(this), 0);
    }

    function borrowUsdc(uint256 amount) external {
        IPool(POOL).borrow(USDC, amount, 2, 0, address(this));
    }

    function repayUsdc(uint256 amount) external {
        IERC20(USDC).approve(POOL, amount);
        IPool(POOL).repay(USDC, amount, 2, address(this));
    }
}
