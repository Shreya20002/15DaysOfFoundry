// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MultiSigWallet} from "../src/Wallet.sol";

contract MultiSigWalletScript is Script {
    function run() public {
        vm.startBroadcast();
        
        address[] memory owners = new address[](3);
        owners[0] = address(1);
        owners[1] = address(2);
        owners[2] = address(3);
        
        new MultiSigWallet(owners, 2);
        
        vm.stopBroadcast();
    }
}
