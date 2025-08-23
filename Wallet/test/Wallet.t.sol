
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MultiSigWallet} from "../src/Wallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet public wallet;
    address[] public owners;
    uint256 public required = 2;

    address public owner1;
    address public owner2;
    address public owner3;

    function setUp() public {
        owner1 = address(1);
        owner2 = address(2);
        owner3 = address(3);

        owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        wallet = new MultiSigWallet(owners, required);

        // Fund the wallet
        vm.deal(address(wallet), 100 ether);
    }

    function testSubmitTransaction() public {
        vm.prank(owner1);
        wallet.submit(address(0x123), 1 ether, "");
        
        (address to, uint value, bytes memory data, bool executed) = wallet.transactions(0);
        assertEq(to, address(0x123));
        assertEq(value, 1 ether);
        assertEq(executed, false);
    }

    function testApproveAndExecute() public {
        vm.prank(owner1);
        wallet.submit(address(0x123), 1 ether, "");

        vm.prank(owner1);
        wallet.approve(0);

        vm.prank(owner2);
        wallet.approve(0);

        uint preBalance = address(0x123).balance;
        
        vm.prank(owner1);
        wallet.execute(0);

        assertEq(address(0x123).balance, preBalance + 1 ether);
    }
}
