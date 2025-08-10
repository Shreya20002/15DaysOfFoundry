// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Greeting} from "../src/Greeting.sol";

contract GreetingScript is Script {
    Greeting public greeting;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy the Greeting contract with an initial greeting
        greeting = new Greeting("Welcome to Foundry!");
        
        console.log("Greeting contract deployed to:", address(greeting));
        console.log("Initial greeting:", greeting.getGreeting());

        vm.stopBroadcast();
    }
}
