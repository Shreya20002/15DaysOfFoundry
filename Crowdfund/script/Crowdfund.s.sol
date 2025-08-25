// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Crowdfund.sol";

contract DeployCrowdfund is Script {
    function run() external returns (Crowdfund) {
        // 1 Ether goal, 7 day duration
        uint256 goal = 1 ether;
        uint256 duration = 7 days;

        vm.startBroadcast();
        Crowdfund crowdfund = new Crowdfund(goal, duration);
        vm.stopBroadcast();
        
        return crowdfund;
    }
}
