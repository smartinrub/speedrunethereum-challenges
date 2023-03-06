// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    // VARIABLES
    ExampleExternalContract public exampleExternalContract;
    mapping(address => uint256) public balances;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 72 hours;
    bool openForWithdraw = false;

    // EVENTS
    event Stake(address sender, uint256 value);

    // MODIFIERS
    modifier deadlineExpired(bool deadlineExpiredRequired) {
        uint256 remainingTime = timeLeft();
        if (deadlineExpiredRequired) {
            require(remainingTime == 0, "Deadline not expired yet!");
        } else {
            require(remainingTime > 0, "Deadline is already expired!");
        }
        _;
    }

    modifier notCompleted() {
        bool completed = exampleExternalContract.completed();
        require(!completed, "Execution has been already performed!");
        _;
    }

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    function stake() public payable deadlineExpired(false) {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function execute() public notCompleted deadlineExpired(true) {
        uint256 contractBalance = address(this).balance;
        if (contractBalance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }

    function withdraw() public notCompleted deadlineExpired(true) {
        require(openForWithdraw, "Not open for withdraw!");
        uint256 userBalance = balances[msg.sender];
        require(userBalance > 0, "You don't have funds staked");

        balances[msg.sender] = 0;
        payable(msg.sender).transfer(userBalance);
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }

        return deadline - block.timestamp;
    }

    receive() external payable {
        stake();
    }
}
