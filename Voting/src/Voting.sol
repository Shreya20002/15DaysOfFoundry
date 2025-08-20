// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Voting {
    struct Proposal {
        string description;
        uint256 voteCount;
        bool exists;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    uint256 public proposalCount;
    address public owner;

    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(uint256 indexed proposalId, address indexed voter);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function createProposal(string memory _description) public onlyOwner {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            description: _description,
            voteCount: 0,
            exists: true
        });
        
        emit ProposalCreated(proposalCount, _description);
    }

    function vote(uint256 _proposalId) public {
        require(proposals[_proposalId].exists, "Proposal doesn't exist");
        require(!hasVoted[msg.sender][_proposalId], "Already voted");

        proposals[_proposalId].voteCount++;
        hasVoted[msg.sender][_proposalId] = true;

        emit Voted(_proposalId, msg.sender);
    }

    function getProposal(uint256 _proposalId) public view returns (
        string memory description,
        uint256 voteCount
    ) {
        require(proposals[_proposalId].exists, "Proposal doesn't exist");
        Proposal storage proposal = proposals[_proposalId];
        return (proposal.description, proposal.voteCount);
    }
}