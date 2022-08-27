// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

contract General_Elections {

    struct VoteEntry {
        uint id; 
        bool voted;  
        uint vote;
    }

    struct BallotEntry {
        string name;
        uint voteCount;
    }

    address public myMaker;

    mapping(address => VoteEntry) public votersDetails;

    BallotEntry[] public Ballot;

    mapping (address => bool) public votingAddresses;

    uint endTime;

    uint numberOfVoters; 


    modifier onlyOwner {
        require(
            msg.sender == myMaker,
            "Only myMaker."
        );
        _;
    }

    constructor(string[] memory candidates) {
        myMaker = msg.sender;

        for (uint i = 0; i < candidates.length; i++) {
            Ballot.push(BallotEntry({
                name: candidates[i],
                voteCount: 0
            }));
        }
    }

    function addVoter(address voterAddress) public onlyOwner{
        require(block.timestamp < endTime, "Time up for registration");
        require(votingAddresses[voterAddress] == false, "Voter already registered.");
        require(!votersDetails[voterAddress].voted, "The voter already voted.");
        votingAddresses[voterAddress]=true;
        votersDetails[voterAddress].id = ++numberOfVoters;
    }

    function startVote(uint _endTime) public onlyOwner{
        require(_endTime > block.timestamp, "Future time required");
        endTime = _endTime;
    }

    function vote(uint candidateNumber) public {
        require(block.timestamp < endTime, "Time up for voting");
        VoteEntry storage sender = votersDetails[msg.sender];
        require(votingAddresses[msg.sender], "Is not registered");
        require(!sender.voted, "Already voted.");
        sender.vote = candidateNumber;
        sender.voted = true;
        Ballot[candidateNumber].voteCount += 1;
    }

    function countVotes() public view onlyOwner
            returns (uint winner)
    {
        require(block.timestamp > endTime, "Time is not up for voting");

        uint winningVoteCount = 0;
        for (uint p = 0; p < Ballot.length; p++) {
            if (Ballot[p].voteCount > winningVoteCount) {
                winningVoteCount = Ballot[p].voteCount;
                winner = p;
            }
        }
    }

    function showWinner() public view
            returns (string memory winnerName_)
    {
        winnerName_ = Ballot[countVotes()].name;
    }

    function getEndTime() public view returns(uint _endTime){
        return endTime;
    }

    function isVoter(address voterAddress) public view returns (bool){
        return votingAddresses[voterAddress];
    }

    function getNumberOfVoters() public view returns(uint _noOfVoters){
        return numberOfVoters; 
    }
}
