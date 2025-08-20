// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Voting} from "../src/Voting.sol";

contract VotingScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        
        // Deploy Voting contract
        Voting voting = new Voting();
        
        // Create initial proposals
        voting.createProposal("Proposal #1: Implement Feature A");
        voting.createProposal("Proposal #2: Implement Feature B");
        
        vm.stopBroadcast();
    }
}