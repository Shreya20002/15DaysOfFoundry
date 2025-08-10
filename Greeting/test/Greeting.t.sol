// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Greeting} from "../src/Greeting.sol";

contract GreetingTest is Test {
    Greeting public greeting;
    string public initialGreeting = "Hello, World!";

    function setUp() public {
        greeting = new Greeting(initialGreeting);
    }

    function test_InitialGreeting() public {
        assertEq(greeting.getGreeting(), initialGreeting);
    }

    function test_SetGreeting() public {
        string memory newGreeting = "Hello, Foundry!";
        greeting.setGreeting(newGreeting);
        assertEq(greeting.getGreeting(), newGreeting);
    }

    function test_Greet() public {
        string memory expected = "Hello! Hello, World!";
        assertEq(greeting.greet(), expected);
    }

    function test_OwnerIsDeployer() public {
        assertEq(greeting.getOwner(), address(this));
    }

    function test_GreetingUpdatedEvent() public {
        string memory newGreeting = "Testing events!";
        
        vm.expectEmit(true, true, true, true);
        emit Greeting.GreetingUpdated(newGreeting, address(this), 1);
        
        greeting.setGreeting(newGreeting);
    }

    function testFuzz_SetGreeting(string memory randomGreeting) public {
        greeting.setGreeting(randomGreeting);
        assertEq(greeting.getGreeting(), randomGreeting);
    }
}
