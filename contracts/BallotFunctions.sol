// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;

import './Alexandria.sol';
import './Eniko.sol';
import './Ballot.sol';
import './BallotList.sol';
import './ConsequenceFunctions.sol';
import './BallotDeployer.sol';

contract BallotFunctions is EnikoApp {

    // Constructor
    
    constructor(address payable eniko_) {
        eniko = eniko_;
    }

    // External Functions

    // Getters

    function getVoteOptionsCount(address ballot_) external view returns (uint count_) {
        count_ = Ballot(ballot_).getVoteOptionsCount();
    }

    function getResult(address ballot_, uint option_) external view returns (uint result_) {
        Ballot ballot = Ballot(ballot_);
        require(option_ < ballot.getVoteOptionsCount(), "Invalid option");
        result_ = ballot.getNodeVoteCount(ballot.voteOptions(option_));
    } 

    function getVoteOptionTitle(address ballot_, uint option_) external view returns (bytes32 title_) {
        require(option_ < Ballot(ballot_).getVoteOptionsCount(), "Invalid option");
        title_ = Ballot(ballot_).getNodeTitle(Ballot(ballot_).voteOptions(option_));
    }

    function getVoteOptionAddress(address ballot_, uint option_) external view returns (address address_) {
        require(option_ < Ballot(ballot_).getVoteOptionsCount(), "Invalid option");
        address_ = Ballot(ballot_).voteOptions(option_);
    }

    function getTitle(address ballot_) external view returns(string memory title_) {
        title_ = Ballot(ballot_).title();
    }

    function getDetails(address ballot_) external view returns(string memory details_) {
        details_ = Ballot(ballot_).details();
    }

    function getProposer(address ballot_) external view returns(address proposer_) {
        proposer_ = Ballot(ballot_).proposer();
    }

    function getCloseTime(address ballot_) external view returns(uint closeTime_) {
        closeTime_ = Ballot(ballot_).closeTime();
    }

    function isBallotOpen(address ballot_) external view returns(bool ballotOpen_) {
        ballotOpen_ = Ballot(ballot_).ballotOpen();
    }

    function getBallots() external view returns(address[] memory ballots_) {
        ballots_ = getBallotListApp().getBallots();
    }

    function getCurrentVote(address ballot_, address node_) external view returns(address choice_) {
        choice_ = Ballot(ballot_).getNodeChoice(node_);
    }

    function getNodeFollowers(address ballot_, address node_) external view returns(address[] memory followers_) {
        followers_ = Ballot(ballot_).getNodeFollowers(node_);
    }

    function isDescendant(address ballot_, address parent_, address descendant_) external view returns(bool isDescendant_) {
        isDescendant_ = false;
        if (parent_ == address(0)) {
            Ballot ballot = Ballot(ballot_);
            uint i = 0;
            while (!isDescendant_ && i < ballot.getVoteOptionsCount()) {
                if (checkIfDescendant(ballot_, ballot.voteOptions(i),descendant_)) {
                    isDescendant_ = true;
                }
                i++;
            }
        }
        else {
            isDescendant_ = checkIfDescendant(ballot_, parent_, descendant_);
        }
    }

    // Setters

    function createBallot(string memory title_, string memory details_, bytes32[] memory options_, uint enikoApp_, address[] memory appAddresses_, uint length_) external {
        require(bytes(title_).length < 64, "Title must be less than 64 bytes");
        require(msg.sender == Eniko(eniko).getFounder(), "403"); // Change this once the Solution functionality is complete
        uint closeTime = 0;
        if (length_<14) {
            closeTime = block.timestamp + 14 days;
        } else {
            closeTime = block.timestamp + length_  * (1 days);
        }
        Ballot ballot = BallotDeployer(Eniko(eniko).getAppAddress(8)).deployBallot();
        // Set variables
        ballot.setTitle(title_);
        ballot.setDetails(details_);
        ballot.setEnikoApp(enikoApp_);
        ballot.setProposer(msg.sender);
        ballot.setBallotOpen(true);
        ballot.setCloseTime(closeTime);
        
        // Set the abstention vote by creating a fake address. Only the purpose is allowed to vote for abstention and should be set by default to abstention
        address abstainAddress = address(bytes20(keccak256(abi.encodePacked(address(ballot), bytes32("Abstain"))))); 
        ballot.addVoteOption(abstainAddress);
        address[] memory followers;
        ballot.addVoteTreeNode(abstainAddress, bytes32("Abstain"), followers, address(0x00), true, 0, false);
        

        // Create the other voting options within the Vote Tree
        // If it is not a vote to replace/add an enikoApp, enikoApp_ = 0, create fake addresses
        if (enikoApp_ == 0) {
            for (uint i = 0; i < options_.length; i++) {
                if(options_[i] != bytes32("Abstain")) {
                    address optionAddress = address(bytes20(keccak256(abi.encodePacked(address(ballot), options_[i]))));
                    ballot.addVoteOption(optionAddress);
                    ballot.addVoteTreeNode(optionAddress, options_[i], followers, address(0x00), true, 0, false);
                }
            }

        }
        // Otherwise use the appAddresses
        else {
            for (uint i = 0; i < appAddresses_.length; i++) {
                if(options_[i] != bytes32("Abstain")) {
                    ballot.addVoteOption(appAddresses_[i]);
                    ballot.addVoteTreeNode(appAddresses_[i], options_[i], followers, address(0x00), true, 0, false);
                }
            }
        } 

        // Add the purpose as a voting node
        address purpose = Eniko(eniko).getPurpose();
        addVoterToBallot(ballot, purpose, "", followers, abstainAddress, true, 0, false);
        // Add its children
        addConsequenceDescendantsToVoteTree(ballot, purpose);

        // Add the ballot to the Ballot List
        getBallotListApp().addBallot(address(ballot));
    }
    
    
    function changeMyVote(address ballot_, address newChoice_, address consequence_) external {
        Ballot ballot = Ballot(ballot_);
        require(ballot.ballotOpen(), "Ballot closed");
        if(ballot.closeTime() < block.timestamp) {closeBallot(ballot);}
        else {
            require(getConsequenceFunctionsApp().getAuthor(consequence_) == msg.sender, "403");
            bool hasAVote = false;
            uint i = 0;
            while (!hasAVote && i < ballot.getVoteOptionsCount()) {
                if (checkIfDescendant(ballot_, ballot.voteOptions(i) ,consequence_)) {
                    hasAVote = true;
                }
                i++;
            }
            require(hasAVote,"Consequence has no vote");
            require(ballot.getNodeExists(newChoice_), "Invalid choice");
            require(!checkIfDescendant(ballot_, consequence_, newChoice_) && newChoice_ != consequence_, "Circular vote" );

            // Remove from the original choice
            ballot.removeNodeFollower(ballot.getNodeChoice(consequence_), consequence_);
        
            // Add to the new choice
            ballot.addNodeFollower(newChoice_, consequence_);
        
            // Change choice
            ballot.setNodeChoice(consequence_, newChoice_);
            ballot.setNodeTookAction(consequence_, true);
        }
    }

    function manuallyCloseBallot(address ballot_) external {
        Ballot ballot = Ballot(ballot_);
        require(ballot.closeTime() < block.timestamp, "Too early");
        closeBallot(ballot);
    }

    function deleteBallot(address ballot_) external {
        require(msg.sender == Ballot(ballot_).proposer(), "403");
        getBallotListApp().removeBallot(ballot_);
        Ballot(ballot_).destroy();
    }

    // Internal Functions

    function checkIfDescendant(address ballot_, address parent_, address descendant_) internal view returns(bool result_) {
        result_ = false;
        uint i = 0;
        // Check the direct children first for efficiency sake
        while (!result_ && i < Ballot(ballot_).getNodeFollowersCount(parent_)) {
            if (Ballot(ballot_).getNodeFollower(parent_, i) == descendant_) {
                result_ = true;
            }
            i++;
        }
        // Now check the descendants of each child
        i = 0;
        while (!result_ && i < Ballot(ballot_).getNodeFollowersCount(parent_)) {
            if (checkIfDescendant(ballot_, Ballot(ballot_).getNodeFollower(parent_, i), descendant_)) {
                result_ = true;
            }
            i++;
        }
    }

    function addConsequenceDescendantsToVoteTree(Ballot ballot_, address consequence_) internal {
        ConsequenceFunctions consequenceFunctions = getConsequenceFunctionsApp();
        address[] memory children = consequenceFunctions.getChildren(consequence_);
        for (uint i = 0; i < children.length; i++) {
            address child = children[i];
            if (consequenceFunctions.getType(child) == Alexandria.ConsequenceType.Public) {
                address[] memory followers;
                addVoterToBallot(ballot_, child, "", followers, consequence_, true, 0, false);
                addConsequenceDescendantsToVoteTree(ballot_, child);
            }
        }
    }

    function addVoterToBallot(Ballot ballot_, address consequence_, bytes32 title_, address[] memory followers_, address choice_, bool exists_, uint voteCount_, bool tookAction_) internal {
        ballot_.addVoteTreeNode(consequence_, title_, followers_, choice_, exists_, voteCount_, tookAction_);
        ballot_.addNodeFollower(choice_, consequence_);
        ballot_.incrementAuthorVoteCount(getConsequenceFunctionsApp().getAuthor(consequence_));
    }

    function countVotes(Ballot ballot_) internal {
        for (uint i = 0; i < ballot_.getVoteOptionsCount(); i++) {
            uint count = countOptionVotes(ballot_, ballot_.voteOptions(i));
            ballot_.setNodeVoteCount(ballot_.voteOptions(i), count);
        }
    }

    function countOptionVotes(Ballot ballot_, address option_) internal returns (uint count_)  {
        ConsequenceFunctions consequenceFunctions = getConsequenceFunctionsApp();
        count_ = 0;
        for (uint i = 0; i < ballot_.getNodeFollowersCount(option_); i++) {
            address child = ballot_.getNodeFollower(option_, i);
            count_ = count_ + (1 ether) / ballot_.authorVoteCount(consequenceFunctions.getAuthor(child));
            count_ = count_ + countOptionVotes(ballot_, child);
            if (ballot_.getNodeTookAction(child)) {
                consequenceFunctions.resetMissedVotes(child);
            }
            else {
                consequenceFunctions.missedVote(child);
            }
        }
    }

    function getWinner(Ballot ballot_) internal view returns (address winner_) {
        // The first option is always the abstention vote so ignore it
        winner_ = ballot_.voteOptions(1);
        for (uint i = 1; i < ballot_.getVoteOptionsCount(); i++) {
            if (ballot_.getNodeVoteCount(ballot_.voteOptions(i)) > ballot_.getNodeVoteCount(winner_)) {
                winner_ = ballot_.voteOptions(i);
            }
        }
    }

    function closeBallot(Ballot ballot_) internal {
        require(ballot_.ballotOpen());
        ballot_.setBallotOpen(false);
        countVotes(ballot_);
        // If it is a vote to replace an Eniko app then do so
        if (ballot_.enikoApp() > 0) {
            Eniko(eniko).updateAppAddress(ballot_.enikoApp(), getWinner(ballot_));
        }
    }

    // Eniko App Retrievers

    function getConsequenceFunctionsApp() internal view returns (ConsequenceFunctions app_) {
        app_ = ConsequenceFunctions(Eniko(eniko).getAppAddress(4));
    }

    function getBallotListApp() internal view returns (BallotList app_) {
        app_ = BallotList(Eniko(eniko).getAppAddress(9));
    }

}