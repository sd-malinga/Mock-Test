//SPDX-License-Identifier: Unlicensed
// this contrract is only for the fractional NFTs

pragma solidity ^0.8.0;

import './fractional.sol';

contract dutchAuction is ReentrancyGuard {
    uint256 auctionId;
    DragonFractionalNFT public fractionMachine;
    struct AuctionItem{
        uint256 tokenId;
        uint256 amount;
        address payable seller;
        uint256 startingPrice; // per token
        uint256 discountRate; //per hour with 2 decimals
        uint256 startAt;
        uint256 expiresAt;
        uint256 amountsold;
    }
    event AuctionCreated(
        uint256 tokenId,
        uint256 amount,
        address payable seller,
        uint256 startingPrice, // per token
        uint256 discountRate, //per hour with 2 decimals
        uint256 startAt,
        uint256 expiresAt
    );
    event Sold(
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 amount
    );
    mapping(uint256 => AuctionItem) public auctionInfo;
    constructor(DragonFractionalNFT splitter){
        fractionMachine = splitter;
    }
    function createAuction(uint256 tokenId, uint256 amount, uint256 endTime, uint256 startPrice, uint256 discount) external nonReentrant {
        address conadd = fractionMachine.checkFractionalContract(tokenId);
        require(conadd != address(0), "Fractions Not Present");
        require(endTime> block.timestamp, "End Time must be of future");
        require(discount<=10000, "Discount should be equal to or less than 100%");
        auctionId++;
        IERC20(conadd).transferFrom(msg.sender, address(this), amount);
        auctionInfo[auctionId] = AuctionItem(
            tokenId,
            amount,
            payable (msg.sender),
            startPrice,
            discount,
            block.timestamp,
            endTime,
            0
        );
        emit AuctionCreated(  
            tokenId,
            amount,
            payable (msg.sender),
            startPrice,
            discount,
            block.timestamp,
            endTime
            );

    }

    function checkPrice(uint256 tokenId) public view returns(uint256) {
        uint256 timeElapsed = block.timestamp - auctionInfo[tokenId].startAt / (60*60);
        uint256 discount = auctionInfo[tokenId].discountRate * timeElapsed / (100*100);
        return (auctionInfo[tokenId].startingPrice - discount);
    }

   function isAuctionLive(uint256 tokenId) public view returns(bool){
        if(
            auctionInfo[tokenId].expiresAt > block.timestamp && 
            auctionInfo[tokenId].amountsold < auctionInfo[tokenId].amount) 
            {
            return true;
            }
        else 
            {
                return false;
            }
    }

    function buyNow(uint256 tokenId, uint256 amount) external nonReentrant payable {
        require(isAuctionLive(tokenId)==true, "Already Sold or Ended");
        address conadd = fractionMachine.checkFractionalContract(tokenId);
        uint256 price = amount * checkPrice(tokenId);
        require(msg.value==price, "Send correct Amount in Value");
        auctionInfo[tokenId].seller.transfer(msg.value);
        auctionInfo[tokenId].amountsold += amount;
        IERC20(conadd).transfer(msg.sender, amount);
        emit Sold(
            tokenId,
            msg.sender,
            amount
        );
    }

 

}
