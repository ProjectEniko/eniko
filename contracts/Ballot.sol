// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;

import './Alexandria.sol';
import './Eniko.sol';

contract Ballot {
    
    modifier limitedAccess {
        require(msg.sender == Eniko(eniko).getAppAddress(7) || msg.sender == Eniko(eniko).getAppAddress(8));
        _;
    }

    // The actual ballot choices are included in the vote tree as if they were voters but their choice is set to address zero
    // This enables 'real' voters to allocate their vote to a choice in the same way as they allocate to another voter
    // Each 'real' voter matches a consequence or the purpose
    address payable public eniko;                                      // The root Eniko contract
    string public title;                                               // The title of the ballot
    string public details;                                             // Details of the ballot
    uint public enikoApp;                                              // The Eniko App which the proposer is proposing to replace with the winning address. Or 0 if it is not a proposal to replace an app
    address public proposer;                                           // The address of the person or contract who proposed the ballot
    uint public closeTime;                                             // The time at which the ballot will close
    bool public ballotOpen;                                            // Indicator that the ballot is still open
    mapping(address => uint) public authorVoteCount;                   // The number of votes (consequences) each author has, used to weight their votes
                                                                        // More votes means lower weighting so that each author is equal irrespective of the number of consequences they have
    address[] public voteOptions;                                      // A list of the real voting options, including abstention
    mapping(address => Alexandria.VoterDetails) private voteTree;       // A tree including all voters and their selected vote


    constructor(address payable eniko_) {
        eniko = eniko_;
    }
    

    // Admin Functions

    function destroy() external limitedAccess  {
        selfdestruct(eniko);
    }


    // Getters

    function getVoteOptions() external view returns(address[] memory voteOptions_) {
        voteOptions_ = voteOptions;
    }

    function getVoteOptionsCount() external view returns(uint count_) {
        count_ = voteOptions.length;
    }

    // Getters - voteTree

    function getNodeChoice(address node_) external view returns(address choice_) {
        choice_ = voteTree[node_].choice;
    }

    function getNodeFollowers(address node_) external view returns(address[] memory followers_) {
        followers_ = voteTree[node_].followers;
    }

    function getNodeFollowersCount(address node_) external view returns(uint count_) {
        count_ = voteTree[node_].followers.length;
    }

    function getNodeFollower(address node_, uint index_) external view returns(address follower_) {
        follower_ = voteTree[node_].followers[index_];
    }

    function getNodeTitle(address node_) external view returns(bytes32 title_) {
        title_ = voteTree[node_].title;
    }

    function getNodeExists(address node_) external view returns(bool exists_) {
        exists_ = voteTree[node_].exists;
    }

    function getNodeVoteCount(address node_) external view returns (uint voteCount_) {
        voteCount_ = voteTree[node_].voteCount;
    } 

    function getNodeTookAction(address node_) external view returns (bool tookAction_) {
        tookAction_ = voteTree[node_].tookAction;
    }


    // Setters

    function setEniko(address payable eniko_) external limitedAccess {
        eniko = eniko_;
    }

    function setTitle(string memory title_) external limitedAccess {
        title = title_;
    }

    function setDetails(string memory details_) external limitedAccess {
        details = details_;
    }

    function setEnikoApp(uint enikoApp_) external limitedAccess {
        enikoApp = enikoApp_;
    }

    function setProposer(address proposer_) external limitedAccess {
        proposer = proposer_;
    }

    function setCloseTime(uint closeTime_) external limitedAccess {
        closeTime = closeTime_;
    }

    function setBallotOpen(bool ballotOpen_) external limitedAccess {
        ballotOpen = ballotOpen_;
    }

    function setAuthorVoteCount(address author_, uint count_) external limitedAccess {
        authorVoteCount[author_] = count_;
    }

    function incrementAuthorVoteCount(address author_) external limitedAccess {
        authorVoteCount[author_]++;
    }

    function decrementAuthorVoteCount(address author_) external limitedAccess {
        authorVoteCount[author_]--;
    }

    function addVoteOption(address option_) external limitedAccess {
        voteOptions.push(option_);
    }

    function removeVoteOption(address option_) external limitedAccess {
        uint j = 0;
        for (uint i = 0; i < voteOptions.length; i++) {
            if (voteOptions[i] == option_) {
                j++;
            }
            else {
                if (j>0) {
                    voteOptions[i-j] = voteOptions[i];
                }
            }
        }
        for (uint i = 0; i < j; i++) {
            voteOptions.pop();
        }
    }

    // Setters - voteTree

    function addVoteTreeNode(address node_, bytes32 title_, address[] memory followers_, address choice_, bool exists_, uint voteCount_, bool tookAction_) external limitedAccess {
        voteTree[node_] = Alexandria.VoterDetails({title: title_, followers: followers_, choice: choice_, exists: exists_, voteCount: voteCount_, tookAction: tookAction_});
    }

    function setNodeChoice(address node_, address choice_) external limitedAccess {
        voteTree[node_].choice = choice_;
    }

    function addNodeFollower(address node_, address follower_) external limitedAccess {
        voteTree[node_].followers.push(follower_);
    }

    function removeNodeFollower(address node_, address follower_) external limitedAccess {
        uint j = 0;
        for (uint i = 0; i < voteTree[node_].followers.length; i++) {
            if (voteTree[node_].followers[i] == follower_) {
                j++;
            }
            else {
                if (j>0) {
                    voteTree[node_].followers[i-j] = voteTree[node_].followers[i];
                }
            }
        }
        for (uint i = 0; i < j; i++) {
            voteTree[node_].followers.pop();
        }
    }

    function setNodeTitle(address node_, bytes32 title_) external limitedAccess {
        voteTree[node_].title = title_;
    }

    function setNodeExists(address node_, bool exists_) external limitedAccess {
        voteTree[node_].exists = exists_;
    }

    function setNodeVoteCount(address node_, uint voteCount_) external limitedAccess {
        voteTree[node_].voteCount = voteCount_;
    }

    function incrementNodeVoteCount(address node_) external limitedAccess {
        voteTree[node_].voteCount++;
    }

    function decrementNodeVoteCount(address node_) external limitedAccess {
        voteTree[node_].voteCount--;
    }

    function setNodeTookAction(address node_, bool tookAction_) external limitedAccess {
        voteTree[node_].tookAction = tookAction_;
    }

}