// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {AaveBorrow} from "../src/AaveBorrow.sol";

contract AaveBorrowScript is Script {
    function run() public {
        vm.startBroadcast();
        new AaveBorrow();
        vm.stopBroadcast();
    }
}