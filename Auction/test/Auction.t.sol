// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Auction} from "../src/Auction.sol";

contract AuctionTest is Test {
    Auction auction;
    address bidder1 = address(0xBEEF);
    address bidder2 = address(0xCAFE);

    function setUp() public {
        auction = new Auction(3600 seconds); // 1 hour auction duration
        vm.deal(bidder1, 10 ether);
        vm.deal(bidder2, 10 ether);
    }

    /*function testBidAndSettle() public {
        // Bidder1 places a bid
        vm.prank(bidder1);
        auction.bid{value: 1 ether}();
        assertEq(auction.highestBidder(), bidder1);
        assertEq(auction.highestBid(), 1 ether);

        // Bidder2 outbids
        vm.prank(bidder2);
        auction.bid{value: 2 ether}();
        assertEq(auction.highestBidder(), bidder2);
        assertEq(auction.highestBid(), 2 ether);

        // Fast forward time to after auction end
        vm.warp(block.timestamp + 7200 seconds);

        // Settle auction
        vm.prank(auction.seller());
        auction.settle();
        assertTrue(auction.settled());
    }
    */

    function testCannotBidAfterEnd() public {
        vm.warp(block.timestamp + 7200 seconds);
        vm.prank(bidder1);
        vm.expectRevert("Auction has ended");

        auction.bid{value: 1 ether}();
    }

    function testCannotSettleTwice() public {
        vm.warp(block.timestamp + 7200 seconds);
        auction.settle();
        vm.expectRevert("Auction has already been settled");
        auction.settle();
    }
}
