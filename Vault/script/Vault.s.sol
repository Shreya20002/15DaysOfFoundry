// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";

contract VaultScript is Script {
    function run() public {
        vm.startBroadcast();
        new Vault();
        vm.stopBroadcast();
    }
}
