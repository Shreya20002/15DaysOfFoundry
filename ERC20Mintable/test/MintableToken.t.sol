// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MintableToken} from "../src/MintableToken.sol";

contract MintableTokenTest is Test {
    MintableToken public token;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = address(0xBEEF);
        token = new MintableToken();
        vm.deal(user, 100 ether);
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), 1000 * 10**token.decimals());
    }

    function testMinting() public {
        uint256 mintAmount = 100 * 10**token.decimals();
        token.mint(user, mintAmount);
        assertEq(token.balanceOf(user), mintAmount);
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not owner");
        token.mint(user, 100);
    }
}