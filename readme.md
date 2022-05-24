# Mock Test

## Deployment Steps

#### 1. Deploy ERC721 Contract named as GameItem from SampleERC721.sol with no constructor parameters
#### 2. Deploy Contract DragonFractionalNFT from fractional.sol with constructor parameter of contract address of deployed contract from step 1.
#### 3. Deploy Contract dutchAuction from dutchAuction.sol with constructor parameter of contract address of deployed contract from step 2.

Latest Deploments
NFT Contract Game Item: 
https://mumbai.polygonscan.com/address/0x381f78d40a18fe000e75ead68492868e5041ae15

DragonFractionalNFT: 
https://mumbai.polygonscan.com/address/0xb2663a9d4e75bfb0eb291be10fc8e00498fd33ca

dutchAuction:
https://mumbai.polygonscan.com/address/0x75bc20887fd4b5c3c4ea000c45a53dfe58e6ebdb


## Overview 

### GameItem Contract
Game Item Contract is a basic contract from the OpenZepplin for sample ERC721 based NFTs. 
We can mint ERC721 tokens using this contract



### DragonFractionalNFT
DragonFractionalNFT is one of the main contract, which can be used to make fractional part of any GameItem ERC721 token of the specified contract.
It takes the NFT from user and deploys a new ERC20 Contract, and then mints the amount of tokens according to the requirement of user.


### dutchAuction
dutchAuction is another main contract, which can be used for conducting dutch auction of the fractions of the GameItem Token. It conducts auction with proper deadline, starting price, discount rate.
The price of the tokens gets continuously decreasing at the rate of discount per hour. 
The ERC20 token holder can conduct the dutch auction and users can buy the amount of tokens using ETH value.


