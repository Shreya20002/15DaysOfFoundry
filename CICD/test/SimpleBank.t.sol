// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SimpleBank} from "../src/SimpleBank.sol";

contract SimpleBankTest is Test {
    SimpleBank public bank;

    function setUp() public {
        bank = new SimpleBank();
    }

    function test_deposit() public {
        bank.deposit{value: 100000}();
    }
}

