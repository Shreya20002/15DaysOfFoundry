// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MintableToken} from "../src/MintableToken.sol";

contract MintableTokenScript is Script {
    function run() public {
        vm.startBroadcast();
        new MintableToken();
        vm.stopBroadcast();
    }
}