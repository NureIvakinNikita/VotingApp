// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Voting {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
        string photoUrl; 
    }

    struct Voter {
        address voterAddress;
        bool registered;
        bool voted;
    }

    Candidate[] public candidates;
    Voter[] public voters;
    address public owner;
    uint public candidatesCount;
    event VotedEvent(uint candidateId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    constructor() {
        owner = msg.sender;
        addCandidate("Donald Trump", "/assets/trump.png");
        addCandidate("Kamala Harris", "/assets/kamala.png");
    }

    function addCandidate(string memory _name, string memory _photoUrl) public onlyOwner {
        candidates.push(Candidate(candidatesCount + 1, _name, 0, _photoUrl));
        candidatesCount++;
    }

    // Реєстрація виборця
    function registerVoter(address voterAddress) internal {
        voters.push(Voter(voterAddress, true, false));
    }

    // Перевіряє, чи зареєстрований виборець
    function isRegistered(address voterAddress) public view returns (bool) {
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i].voterAddress == voterAddress) {
                return true;
            }
        }
        return false;
    }

    // Перевіряє, чи голосував виборець
    function hasVoted(address voterAddress) public view returns (bool) {
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i].voterAddress == voterAddress) {
                return voters[i].voted;
            }
        }
        return false;
    }

    // Голосування
    function vote(uint candidateId) public {
        require(candidateId > 0 && candidateId <= candidates.length, "Invalid candidate");

        // Перевірка реєстрації
        if (!isRegistered(msg.sender)) {
            registerVoter(msg.sender); // Якщо не зареєстрований, реєструємо
        }

        // Перевірка, чи голосував виборець
        require(!hasVoted(msg.sender), "Already voted");

        // Шукаємо виборця і позначаємо його як такого, що проголосував
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i].voterAddress == msg.sender) {
                voters[i].voted = true;
                break;
            }
        }

        // Збільшуємо кількість голосів за кандидата
        candidates[candidateId - 1].voteCount++;

        emit VotedEvent(candidateId);
    }

    // Отримуємо інформацію про кандидата
    function getCandidate(uint candidateId) public view returns (string memory, uint, string memory) {
        require(candidateId > 0 && candidateId <= candidates.length, "Invalid candidate");
        Candidate memory candidate = candidates[candidateId - 1];
        return (candidate.name, candidate.voteCount, candidate.photoUrl);
    }

}
