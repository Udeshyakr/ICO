// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ICO is ERC20, Ownable, ReentrancyGuard {
    // token name and total supply
    // total supply is 100 million. wach token has 18 decimals
    // 1 MNG0 = 1,000,000,000,000,000,000
    // Total MANGO = 10000000,000,000,000,000,000,000 
    
    constructor() ERC20("Mango", "MNGO") {
      _mint(msg.sender, 10e6 * (10**uint256(decimals())));
    }

    uint256 public totalMangoSold = 0;

    uint256 public preSaleLimit = 3e6 * (10**uint256(decimals())); // 30 million
    uint256 public seedSaleLimit = 5e6* (10**uint256(decimals())); // 50 million

    // these should be fetched from orcale in real world situation
    // using const for now
    uint256 currentEthPrice = 3233; // using const eth price
    uint256 dynamicMANGOprice = 4e2; // 1 dollar = 100
    


    function mint(address account, uint256 amount) public onlyOwner returns (bool sucess) {
      require(account != address(0) && amount != uint256(0), "invalid");
      _mint(account, amount);
      return true;
    }

    function changeMNGOprice(uint256 amountInDollar)private onlyOwner{
        dynamicMANGOprice = amountInDollar * 100;
    }
    function changetotalSold(uint256 sold)public onlyOwner{
        totalMangoSold = sold;
    }

    // to calculate amount of mango during buy based on type of sale

    function calculateTokensToBuy(uint256 amountSent) public payable returns(uint256 tokenAmount){
        uint256 amountInDollar = amountSent * currentEthPrice;
        // pre sale calculation for MANGO to be bought   
        if(totalMangoSold < preSaleLimit){
            uint256 availableToBuy =  amountInDollar * 100; // calculating $0.01 per MANGO
            require(((totalMangoSold + availableToBuy) < preSaleLimit), "MNGO not available");
            return availableToBuy;

        }
        // seed sale calculation for MANGO to be bought
        else if(totalMangoSold > preSaleLimit && totalMangoSold < seedSaleLimit){
            uint256 availableToBuy =  amountInDollar * 50; // calculating $0.02 per MANGO
            require(((totalMangoSold + availableToBuy) < seedSaleLimit), "MNGO not available");
            return availableToBuy;
        }
        // public sale with dynamic price
        else if(totalMangoSold > seedSaleLimit && totalMangoSold < 10e6 * (10**uint256(decimals()))){
            uint256 availableToBuy = amountInDollar * (dynamicMANGOprice / 100);
            require(((totalMangoSold + availableToBuy) < 10e6 * (10**uint256(decimals()))), "MNGO not available");
            return availableToBuy;
        }else{
            return 0;
        }
    }

   

    function buy() public payable nonReentrant returns (bool sucess) {
      uint256 amount = calculateTokensToBuy(msg.value);
      require(amount > 0, "can't buy");
      _transfer(owner(), _msgSender(), amount);
      totalMangoSold = totalMangoSold + amount;
      return true;
    }
}
