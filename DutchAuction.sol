//SPDX-License-Identifier: Unlicensed
// this contrract is only for the fractional NFTs

pragma solidity ^0.8.0;

import './fractional.sol';


/// @title A contract for dutchAuction
/// @author Somyaditya Deopuria
/// @notice You can use this contract for duction auction of fractional parts (ERC20) tokens of the ERC721 NFT
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.


contract dutchAuction is ReentrancyGuard {
    uint256 auctionId;
    DragonFractionalNFT public fractionMachine;
    
    /* 
    @dev Structure of Auction Item
    @param tokenId: token id of the NFT
    @param amount: Total amount of ERC20 tokens(Fractions of ERC721) to be sold
    @param seller: wallet address of the seller
    @param startingPrice: Price at which the auction will start
    @param discountRate: Rate of the decrement of the price (rate % in hours)
    @param expiresAt: Deadline of the auction
    @param amountsold: Amount of ERC20 tokens that are sold
     */
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

    /* 
    @dev Initializes the contract
    @param splitter, the contract address of the fractional NFT making contract
     */
    constructor(DragonFractionalNFT splitter){
        fractionMachine = splitter;
    }

    /* 
    @dev Creates Auction of the tokenId's amount of fractional part
    @param tokenId: token id of the NFT
    @param amount: Total amount of ERC20 tokens(Fractions of ERC721) to be sold
    @param endTime: Deadline of the auction
    @param startPrice: Price at which the auction will start
    @param discount: Rate of the decrement of the price (rate % in hours)
    @dev Updates the struct of AuctionItem
     */
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
    /* 
        @dev calculates the price of each token according to the time elapsed
        @return the current price of each token of a particular NFT
    */
    function checkPrice(uint256 tokenId) public view returns(uint256) {
        if(block.timestamp - auctionInfo[tokenId].startAt > 3600){
        uint256 timeElapsed = block.timestamp - auctionInfo[tokenId].startAt / (60*60);
        uint256 discount = auctionInfo[tokenId].discountRate * timeElapsed / (100*100);
        return (auctionInfo[tokenId].startingPrice - discount);
        } else return (auctionInfo[tokenId].startingPrice);
    }
    /* 
    @dev checks whether an auction is live or not
    @return the boolean value whether the auction is live or not
     */
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

    /* 
    @dev buys the amount of token 
    @param tokenId: NFT token id of which parts are being bought
    @param amount: amount of tokens (fractional parts that are being bought
    @dev transfers the appropriate value of the amount of tokens from msg.sender to seller
    @dev transfers the amount of tokens that are being sold to the buyer (msg.sender)
     */

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
