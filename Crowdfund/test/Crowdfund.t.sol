// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Crowdfund.sol";

contract CrowdfundTest is Test {
    Crowdfund crowdfund;
    address constant CREATOR = address(1);
    address constant CONTRIBUTOR_A = address(2);
    address constant CONTRIBUTOR_B = address(3);
    uint256 constant GOAL = 5 ether;
    uint256 constant DURATION = 7 days;

    function setUp() public {
        vm.prank(CREATOR);
        crowdfund = new Crowdfund(GOAL, DURATION);
    }

    function test_ContributeSuccessfully() public {
        vm.prank(CONTRIBUTOR_A);
        crowdfund.contribute{value: 1 ether}();
        assertEq(crowdfund.contributions(CONTRIBUTOR_A), 1 ether);
        assertEq(crowdfund.raisedAmount(), 1 ether);
    }

    function test_Fail_ContributeAfterDeadline() public {
        vm.warp(block.timestamp + DURATION + 1); // Fast-forward time
        vm.prank(CONTRIBUTOR_A);
        vm.expectRevert(Crowdfund.DeadlinePassed.selector);
        crowdfund.contribute{value: 1 ether}();
    }

    function test_PayoutSuccessfully() public {
        // Contribute enough to meet the goal
        vm.prank(CONTRIBUTOR_A);
        crowdfund.contribute{value: 3 ether}();
        vm.prank(CONTRIBUTOR_B);
        crowdfund.contribute{value: 3 ether}();

        // Fast-forward past the deadline
        vm.warp(block.timestamp + DURATION + 1);
        
        uint256 creatorInitialBalance = CREATOR.balance;
        
        vm.prank(CREATOR);
        crowdfund.payout();

        assertEq(crowdfund.raisedAmount(), 0);
        assertEq(CREATOR.balance, creatorInitialBalance + 6 ether);
    }

    function test_Fail_PayoutBeforeGoalMet() public {
        vm.prank(CONTRIBUTOR_A);
        crowdfund.contribute{value: 1 ether}();
        
        vm.warp(block.timestamp + DURATION + 1);
        
        vm.prank(CREATOR);
        vm.expectRevert(Crowdfund.GoalNotReached.selector);
        crowdfund.payout();
    }

    function test_RefundSuccessfully() public {
        vm.prank(CONTRIBUTOR_A);
        crowdfund.contribute{value: 2 ether}();
        
        // Fast-forward past the deadline
        vm.warp(block.timestamp + DURATION + 1);
        
        uint256 contributorInitialBalance = CONTRIBUTOR_A.balance;
        
        vm.prank(CONTRIBUTOR_A);
        crowdfund.refund();
        
        assertEq(contributorInitialBalance + 2 ether, CONTRIBUTOR_A.balance);
        assertEq(crowdfund.contributions(CONTRIBUTOR_A), 0);
    }
}