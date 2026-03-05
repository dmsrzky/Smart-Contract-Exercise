// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleVoting {

    address public owner;

    struct Candidate {
        string name;
        uint voteCount;
    }

    Candidate[] public candidates;

    mapping(address => bool) public hasVoted;

    bool public votingActive = true;

    event VoteCast(address indexed voter, uint candidateIndex);
    event VotingEnded();

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier votingOpen() {
        require(votingActive, "Voting has ended");
        _;
    }

    constructor(string[] memory candidateNames) {
        owner = msg.sender;

        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }
    }

    function vote(uint candidateIndex) public votingOpen {
        require(!hasVoted[msg.sender], "You already voted");
        require(candidateIndex < candidates.length, "Invalid candidate");

        hasVoted[msg.sender] = true;
        candidates[candidateIndex].voteCount += 1;

        emit VoteCast(msg.sender, candidateIndex);
    }

    function endVoting() public onlyOwner {
        votingActive = false;
        emit VotingEnded();
    }

    function getCandidate(uint index) public view returns (string memory, uint) {
        require(index < candidates.length, "Invalid candidate");
        Candidate memory c = candidates[index];
        return (c.name, c.voteCount);
    }

    function getTotalCandidates() public view returns (uint) {
        return candidates.length;
    }
}