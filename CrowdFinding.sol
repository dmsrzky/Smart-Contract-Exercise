// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Crowdfunding {

    address public owner;
    uint public goal;
    uint public deadline;
    uint public totalRaised;
    uint public minimumContribution;

    mapping(address => uint) public contributions;

    bool public withdrawn;
    bool private locked;

    // EVENTS
    event ContributionReceived(address indexed contributor, uint amount);
    event FundsWithdrawn(address indexed owner, uint amount);
    event RefundIssued(address indexed contributor, uint amount);

    // MODIFIERS
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier noReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "Campaign ended");
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Campaign still active");
        _;
    }

    constructor(
        uint _goal,
        uint _durationInMinutes,
        uint _minimumContribution
    ) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInMinutes * 1 minutes);
        minimumContribution = _minimumContribution;
    }

    function contribute() external payable beforeDeadline {
        require(msg.value >= minimumContribution, "Contribution too small");

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;

        emit ContributionReceived(msg.sender, msg.value);
    }

    function withdrawFunds() external onlyOwner afterDeadline noReentrant {
    require(totalRaised >= goal, "Goal not reached");
    require(!withdrawn, "Already withdrawn");

    withdrawn = true;

    uint balance = address(this).balance;

    (bool success, ) = payable(owner).call{value: balance}("");
    require(success, "Transfer failed");

    emit FundsWithdrawn(owner, balance);
    }

    function claimRefund() external afterDeadline noReentrant {
    require(totalRaised < goal, "Goal was reached");

    uint amount = contributions[msg.sender];
    require(amount > 0, "No contribution");

    contributions[msg.sender] = 0;

    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Refund failed");

    emit RefundIssued(msg.sender, amount);
    }

    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }
}