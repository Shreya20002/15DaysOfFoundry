// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ArtNFT} from "../src/NFT.sol";

contract NFTScript is Script {
    function run() public {
        vm.startBroadcast();
        ArtNFT nft = new ArtNFT();
        vm.stopBroadcast();
    }
}