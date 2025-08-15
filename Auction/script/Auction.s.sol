// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Auction} from "../src/Auction.sol";

contract CounterScript is Script {
    Auction public auction;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        auction = new Auction(3600 seconds);

        vm.stopBroadcast();
    }
}
