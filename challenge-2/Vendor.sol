pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    // VARIABLES
    uint256 public constant tokensPerEth = 100;
    YourToken public yourToken;

    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(
        address seller,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // FUNCTIONS
    function buyTokens() public payable {
        uint256 amountOfEth = msg.value;
        require(amountOfEth > 0, "Send some ETH to buy tokens");

        uint256 amountOfTokens = amountOfEth * tokensPerEth;

        address buyer = msg.sender;
        bool sent = yourToken.transfer(buyer, amountOfTokens);
        require(sent, "Failed to transfer token");

        emit BuyTokens(buyer, amountOfEth, amountOfTokens);
    }

    function withdraw() public onlyOwner {
        uint256 vendorBalance = address(this).balance;
        require(vendorBalance > 0, "Vendor does not have any ETH to withdraw");

        address owner = msg.sender;
        (bool sent, ) = owner.call{value: vendorBalance}("");
        require(sent, "Failed to withdraw");
    }

    function sellTokens(uint256 _amount) public {
        require(_amount > 0, "Amount of tokens must be greater than 0");

        address user = msg.sender;
        uint256 userBalance = yourToken.balanceOf(user);
        require(userBalance >= _amount, "User does not have enough tokens");

        uint256 amountOfEth = _amount / tokensPerEth;
        uint256 vendorEthBalance = address(this).balance;
        require(vendorEthBalance >= amountOfEth);

        bool tokensSent = yourToken.transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        require(tokensSent, "Failed to send tokens to the vendor");
        (bool fundsSent, ) = user.call{value: amountOfEth}("");
        require(fundsSent, "Failed to send funds to the user");
    }
}
