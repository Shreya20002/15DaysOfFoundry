// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Greeting {
    string public greeting;
    address public owner;
    uint256 public updateCount;
    
    event GreetingUpdated(string newGreeting, address updatedBy, uint256 count);
    
    constructor(string memory _initialGreeting) {
        greeting = _initialGreeting;
        owner = msg.sender;
        updateCount = 0;
    }
    
    function setGreeting(string memory _newGreeting) public {
        greeting = _newGreeting;
        updateCount++;
        emit GreetingUpdated(_newGreeting, msg.sender, updateCount);
    }
    
    function getGreeting() public view returns (string memory) {
        return greeting;
    }
    
    function greet() public view returns (string memory) {
        return string(abi.encodePacked("Hello! ", greeting));
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }
    
    function getUpdateCount() public view returns (uint256) {
        return updateCount;
    }
    
    function getFullInfo() public view returns (string memory, address, uint256) {
        return (greeting, owner, updateCount);
    }
}
