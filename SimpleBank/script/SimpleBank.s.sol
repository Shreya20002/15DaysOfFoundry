// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SimpleBank} from "../src/SimpleBank.sol";

contract SimpleBankScript is Script {
    SimpleBank public bank;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy the SimpleBank contract
        bank = new SimpleBank();
        
        console.log("SimpleBank deployed to:", address(bank));
        console.log("Owner:", bank.owner());
        console.log("Initial total deposits:", bank.totalDeposits());
        console.log("Initial contract balance:", bank.getContractBalance());

        vm.stopBroadcast();
    }
}
