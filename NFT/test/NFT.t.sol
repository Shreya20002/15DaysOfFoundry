// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ArtNFT} from "../src/NFT.sol";

contract NFTTest is Test {
    ArtNFT public nft;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = address(0xBEEF);
        nft = new ArtNFT();
    }

    function testMint() public {
        string memory uri = "ipfs://QmExample";
        uint256 tokenId = nft.mint(user, uri);
        assertEq(nft.ownerOf(tokenId), user);
        assertEq(nft.tokenURI(tokenId), uri);
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not owner");
        nft.mint(user, "ipfs://QmExample");
    }
}