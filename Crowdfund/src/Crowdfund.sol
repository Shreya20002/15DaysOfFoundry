// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Crowdfund is ReentrancyGuard {
    // --- State Variables ---
    address public immutable creator;
    uint256 public immutable goal; // in wei
    uint256 public immutable deadline;
    uint256 public raisedAmount;
    mapping(address => uint256) public contributions;

    // --- Events ---
    event Contribution(address indexed contributor, uint256 amount);
    event Payout(address indexed creator, uint256 amount);
    event Refund(address indexed contributor, uint256 amount);

    // --- Errors ---
    error DeadlinePassed();
    error GoalNotReached();
    error DeadlineNotPassed();
    error NotCreator();
    error GoalAlreadyReached();
    error NoContribution();

    // --- Constructor ---
    constructor(uint256 _goal, uint256 _durationSeconds) {
        creator = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _durationSeconds;
    }

    // --- Functions ---
    function contribute() external payable nonReentrant {
        if (block.timestamp > deadline) revert DeadlinePassed();

        contributions[msg.sender] += msg.value;
        raisedAmount += msg.value;
        emit Contribution(msg.sender, msg.value);
    }

    function payout() external nonReentrant {
        if (msg.sender != creator) revert NotCreator();
        if (block.timestamp <= deadline) revert DeadlineNotPassed();
        if (raisedAmount < goal) revert GoalNotReached();

        uint256 amount = raisedAmount;
        raisedAmount = 0; // Prevent reentrancy
        emit Payout(creator, amount);

        (bool success, ) = creator.call{value: amount}("");
        require(success, "Transfer failed.");
    }

    function refund() external nonReentrant {
        if (block.timestamp <= deadline) revert DeadlineNotPassed();
        if (raisedAmount >= goal) revert GoalAlreadyReached();
        
        uint256 contributionAmount = contributions[msg.sender];
        if (contributionAmount == 0) revert NoContribution();

        contributions[msg.sender] = 0; // Prevent reentrancy
        emit Refund(msg.sender, contributionAmount);

        (bool success, ) = msg.sender.call{value: contributionAmount}("");
        require(success, "Refund failed.");
    }
}
