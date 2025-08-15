// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Auction {
    address public seller;
    address public highestBidder;
    uint256 public highestBid;
    uint256 public endTime;
    bool public settled;

    event BidPlaced(address indexed bidder, uint256 amount);
    event AuctionSettled(address winner, uint256 amount);

    constructor(uint256 _durationSeconds) {
        seller = msg.sender;
        endTime = block.timestamp + _durationSeconds;
    }

    function bid() external payable {
        require(block.timestamp < endTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");

        // Refund the previous highest bidder
        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid);
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit BidPlaced(msg.sender, msg.value);
    }

    function settle() external {
        require(block.timestamp >= endTime, "Auction is still ongoing");
        require(!settled, "Auction has already been settled");

        settled = true;

        if (highestBidder != address(0)) {
            // Transfer the highest bid amount to the seller
            payable(seller).transfer(highestBid);
            emit AuctionSettled(highestBidder, highestBid);
        }
    }

}
