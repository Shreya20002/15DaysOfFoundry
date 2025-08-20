// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Voting} from "../src/Voting.sol";

contract VotingTest is Test {
    Voting public voting;
    address public owner;
    address public voter1;
    address public voter2;

    function setUp() public {
        owner = address(this);
        voter1 = address(0xBEEF);
        voter2 = address(0xCAFE);
        
        voting = new Voting();
        
        // Fund test addresses
        vm.deal(voter1, 1 ether);
        vm.deal(voter2, 1 ether);
    }

    function testCreateProposal() public {
        voting.createProposal("Test Proposal");
        assertEq(voting.proposalCount(), 1);
        
        (string memory description, uint256 voteCount) = voting.getProposal(1);
        assertEq(description, "Test Proposal");
        assertEq(voteCount, 0);
    }

    function testVoting() public {
        voting.createProposal("Test Proposal");
        
        vm.prank(voter1);
        voting.vote(1);
        
        (,uint256 voteCount) = voting.getProposal(1);
        assertEq(voteCount, 1);
    }

    function testCannotVoteTwice() public {
        voting.createProposal("Test Proposal");
        
        vm.prank(voter1);
        voting.vote(1);
        
        vm.prank(voter1);
        vm.expectRevert("Already voted");
        voting.vote(1);
    }

    function testOnlyOwnerCanCreateProposal() public {
        vm.prank(voter1);
        vm.expectRevert("Not owner");
        voting.createProposal("Test Proposal");
    }
}