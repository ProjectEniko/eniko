// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.5;

import './Alexandria.sol';
import './Eniko.sol';

contract Consequence {
    
    using Alexandria for Alexandria.ConsequenceType;
    using Alexandria for Alexandria.ConsequenceVersion;

    modifier limitedAccess {
        require(msg.sender == Eniko(eniko).getAppAddress(4) || msg.sender == Eniko(eniko).getAppAddress(5));
        _;
    }

    struct Approval {
        address consequence;                        // The consequence that is pending approval
        uint version;                               // The version that is pending approval
        uint timestamp;                             // The time the approval was requested
    }
    
    address payable public eniko;                          // The root eniko contract from which this consequence derives.
    address public author;                                 // The address of the current lead author of the contract
    address[] public coAuthors;                            // Others who have contributed to this consequence
    address public parent;                                 // The address of the parent
    Alexandria.ConsequenceType public consequenceType;     // What is the scope of the consequence 
    address[] public children;                             // An array of all child consequences
    address public inheritor;                              // The address which will inherit this consequence if the author disappears
    uint public missedBallotCount;                         // The number of ballots that this consequence has not taken action on
    Alexandria.ConsequenceVersion[] private versions;      // An array of versions of the consequence in submission order
    Approval[] private pendingApprovals;                   // The approvals which are currently pending approval via this consequence
    

    // Constructor 

    constructor(address payable eniko_) {
        eniko = eniko_;
        versions.push();
    }

    // Admin Functions

    function destroy() external limitedAccess  {
        selfdestruct(eniko);
    }

    // Getters

    function getCoAuthors() external view returns(address[] memory coauthors_) {
        coauthors_ = coAuthors;
    }

    function getCoAuthorsCount() external view returns(uint count_) {
        count_ = coAuthors.length;
    }

    function getChildren() external view returns(address[] memory children_) {
        children_ = children;
    }

    function getChildrenCount() external view returns(uint count_) {
        count_ = children.length;
    }

    // Getters - versions

    function getVersionCount() external view returns(uint versionCount_) {
        versionCount_ = versions.length;
    }
    
    function getTitle(uint version_) external view returns(string memory title_) {
        title_ = versions[version_].title;
    }

    function getContent(uint version_) external view returns(string memory content_) {
        content_ = versions[version_].content;
    }
    
    function getPendingApprovers(uint version_) external view returns(address[] memory pendingApprovers_) {
        pendingApprovers_ = versions[version_].pendingApprovers;
    }

    function getPendingApproverCount(uint version_) external view returns(uint approverCount_) {
        approverCount_ = versions[version_].pendingApprovers.length;
    }

    function getPendingApprover(uint version_, uint index_) external view returns(address approver_) {
        approver_ = versions[version_].pendingApprovers[index_];
    }

    function getDecryptionKey(uint version_, address address_) external view returns(bytes32 encryptedKey_) {
        encryptedKey_ = versions[version_].encryptedKeys[address_];
    }

    function getVersionAuthor(uint version_) external view returns(address coauthor_) {
        coauthor_ = versions[version_].author;
    }

    function getOriginalApproverCount(uint version_) external view returns(uint count_) {
        count_ = versions[version_].originalApproverCount;
    }

    function isRejected(uint version_) external view returns(bool rejected_) {
        rejected_ = versions[version_].rejected;
    }

    // Getters - pendingApprovals

    function getPendingApprovalsCount() external view returns(uint count_) {
        count_ = pendingApprovals.length;
    }

    function getPendingApprovalConsequence(uint index_) external view returns(address consequence_) {
        consequence_ = pendingApprovals[index_].consequence;
    }

    function getPendingApprovalVersion(uint index_) external view returns(uint version_) {
        version_ = pendingApprovals[index_].version;
    }

    function getPendingApprovalTimestamp(uint i_) external view returns(uint timestamp_) {
        timestamp_ = pendingApprovals[i_].timestamp;
    }

    // Setters

    function setEniko(address payable eniko_) external limitedAccess {
        eniko = eniko_;
    }

    function setAuthor(address author_) external limitedAccess {
        author = author_;
    }

    function addCoAuthor(address coauthor_) external limitedAccess {
        coAuthors.push(coauthor_);
    }

    function removeCoAuthor(address coauthor_) external limitedAccess {
        uint j = 0;
        for (uint i = 0; i < coAuthors.length; i++) {
            if (coAuthors[i] == coauthor_) {
                j++;
            }
            else {
                if (j>0) {
                    coAuthors[i-j] = coAuthors[i];
                }
            }
        }
        for (uint i = 0; i < j; i++) {
            coAuthors.pop();
        }
    }

    function setParent(address parent_) external limitedAccess {
        parent = parent_;
    }

    function setType(Alexandria.ConsequenceType type_) external limitedAccess {
        consequenceType = type_;
    }

    function addChild(address consequence_) external limitedAccess {
        children.push(consequence_);
    }

    function removeChild(address consequence_) external limitedAccess {
        uint j = 0;
        for (uint i = 0; i < children.length; i++) {
            if (children[i] == consequence_) {
                j++;
            }
            else {
                if (j>0) {
                    children[i-j] = children[i];
                }
            }
        }
        for (uint i = 0; i < j; i++) {
            children.pop();
        }
    }

    function setInheritor(address inheritor_) external limitedAccess {
        inheritor = inheritor_;
    }

    function setMissedBallotCount(uint count_) external limitedAccess {
        missedBallotCount = count_;
    }

    function incrementMissedBallotCount() external limitedAccess {
        missedBallotCount++;
    }

    function decrementMissedBallotCount() external limitedAccess {
        missedBallotCount--;
    }

    // Setters - versions

    function addVersion(string memory title_, string memory content_, address coauthor_, bool rejected_) external limitedAccess returns(uint versionNumber_) {
        versions.push();
        versionNumber_ = versions.length - 1;
        Alexandria.ConsequenceVersion storage version = versions[versions.length - 1];
        version.title = title_;
        version.content = content_;
        version.author = coauthor_;
        version.rejected = rejected_;
    }
    
    function setTitle(uint version_, string memory title_) external limitedAccess {
        versions[version_].title = title_;
    }

    function setContent(uint version_, string memory content_) external limitedAccess {
        versions[version_].content = content_;
    }
    
    function addPendingApprover(uint version_, address approver_) external limitedAccess {
        versions[version_].pendingApprovers.push(approver_);
    }

    function removePendingApprover(uint version_, address approver_) external limitedAccess {
        uint j = 0;
        for (uint i = 0; i < versions[version_].pendingApprovers.length; i++) {
            if (versions[version_].pendingApprovers[i] == approver_) {
                j++;
            }
            else {
                if (j>0) {
                    versions[version_].pendingApprovers[i-j] = versions[version_].pendingApprovers[i];
                }
            }
        }
        for (uint i = 0; i < j; i++) {
            versions[version_].pendingApprovers.pop();
        }
    }

    function setDecryptionKey(uint version_, address address_, bytes32 encryptedKey_) external limitedAccess {
        versions[version_].encryptedKeys[address_] = encryptedKey_;
    }

    function setVersionAuthor(uint version_, address author_) external limitedAccess {
        versions[version_].author = author_;
    }

    function setOriginalApproverCount(uint version_, uint count_) external limitedAccess {
        versions[version_].originalApproverCount = count_;
    }

    function setRejected(uint version_, bool rejected_) external limitedAccess {
        versions[version_].rejected = rejected_;
    }

    // Setters - pendingApprovals

    function addNewConsequenceToApprove(address consequence_, uint version_, uint timestamp_) external limitedAccess {
        pendingApprovals.push(Approval({consequence: consequence_, version: version_, timestamp: timestamp_}));
    }

    function removeConsequenceToApprove(address consequence_, uint version_) external limitedAccess {
        // Cycle throught the pending approvals and pull forward any to replace the one in question
        uint j = 0;
        for (uint i = 0; i < pendingApprovals.length; i++) {
            if (pendingApprovals[i].consequence == consequence_ && pendingApprovals[i].version == version_) {
                j++;
            }
            else {
                if (j>0) {
                    pendingApprovals[i-j] = pendingApprovals[i];
                }
            }
        }
        // Delete any pending approvals that have been pulled forward but not replaced
        for (uint i = 0; i < j; i++) {
            pendingApprovals.pop();
        }
    }

    function setPendingApprovalConsequence(uint index_, address consequence_) external limitedAccess {
        pendingApprovals[index_].consequence = consequence_;
    }

    function setPendingApprovalVersion(uint index_, uint version_) external limitedAccess {
        pendingApprovals[index_].version = version_;
    }

    function setPendingApprovalTimestamp(uint index_, uint timestamp_) external limitedAccess {
        pendingApprovals[index_].timestamp = timestamp_;
    }

}