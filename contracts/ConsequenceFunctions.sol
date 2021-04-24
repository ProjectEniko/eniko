// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;

import './Alexandria.sol';
import './Eniko.sol';
import './Consequence.sol';
import './ConsequenceDeployer.sol';
import './Citizens.sol';

contract ConsequenceFunctions is EnikoApp {
    
    using Alexandria for Alexandria.ConsequenceType;
    using Alexandria for Alexandria.ConsequenceVersion;

    // Constructor
    constructor(address payable eniko_) {
        eniko = eniko_;
    }

    function getEniko() external view returns(address payable eniko_) {
        eniko_ = eniko;
    }
    
    // Modifiers to control access

    // Check access to the consequence, irrespective of the version
    modifier checkConsequenceAccess(Consequence consequence_) {
        require(hasAccess(consequence_, msg.sender), "403");
        _;
    }

    // Check conditions and then process an approval
    modifier consequenceApproval(Consequence consequence_, uint version_, address onBehalf_) {
        // Check if the author needs to be changed (this is the author of the consequence being approved, not the one doing the approving; it would be unnecessarily pedantic to prevent the approver from doing the approving)
        checkAuthorOverdue(consequence_);
        // The version must exist
        require(version_ < consequence_.getVersionCount());
        // The consequence must be still pending approval
        require(consequence_.getPendingApproverCount(version_) > 0 && !consequence_.isRejected(version_), "pending");
        // The consequence on behalf of which the approval is bing given must be an approver of the consequence to be approved
        require(checkPendingApprover(consequence_, version_, onBehalf_), "approver");
        // User must be the author of the consequecen they are approving on behalf of
        require(msg.sender == Consequence(onBehalf_).author(), "author");
        // Process specific tasks - reject or approve
        _;
    }

    // Check if sender is the BallotFunctions contract
    modifier ballotFunctionsOnly {
        require(msg.sender == Eniko(eniko).getAppAddress(7), "403");
        _;
    }


    // External Functions

    // Getters
    
    function getType(address consequence_) external view returns(Alexandria.ConsequenceType type_) {
        type_ = Consequence(consequence_).consequenceType();
    }
     
    function getAuthor(address consequence_) external view returns(address author_) {  
        author_ = Consequence(consequence_).author();
    }

    function getCoAuthors(address consequence_) external view returns(address[] memory coauthors_) {
        coauthors_ = Consequence(consequence_).getCoAuthors();
    }

    function getChildren(address consequence_) external view returns(address[] memory children_) {
        children_ = Consequence(consequence_).getChildren();
    }

    function getParent(address consequence_) external view returns(address parent_) {
        parent_ = getParentSafe(consequence_);
    }

    function getProvisionalParent(address consequence_) external view returns(address parent_) {
        parent_ = Consequence(consequence_).parent();
    }

    function checkAccess(address consequence_) external view returns(bool access_) {
        access_ = hasAccess(Consequence(consequence_), msg.sender);
    }

    // Users should say which version they want to retrieve
    function getTitle(address consequence_, uint version_) external view returns(string memory title_) {
        version_ = correctVersionNumber(Consequence(consequence_), version_);
        title_ = Consequence(consequence_).getTitle(version_);
    }

    // Users should say which version they want to retrieve
    function getContent(address consequence_, uint version_) external view returns(string memory content_) {
        version_ = correctVersionNumber(Consequence(consequence_), version_);
        content_ = Consequence(consequence_).getContent(version_);
    }

    // Users should say which version they want to retrieve
    function getVersionAuthor(address consequence_, uint version_) external view returns(address author_) {
        version_ = correctVersionNumber(Consequence(consequence_), version_);
        author_ = Consequence(consequence_).getVersionAuthor(version_);
    }

    function getPendingApprovers(address consequence_, uint version_) external view returns(address[] memory approvers_) {
        version_ = correctVersionNumber(Consequence(consequence_), version_);
        approvers_ = Consequence(consequence_).getPendingApprovers(version_);
    }
    
    function getDecryptionKey(address consequence_, uint version_) external view returns (bytes32 key_) {
        key_ = Consequence(consequence_).getDecryptionKey(version_, msg.sender);
    }

    function getInheritor(address consequence_) external view returns(address inheritor_) {
        Consequence consequence = Consequence(consequence_);
        inheritor_ = consequence.inheritor();
    }
    
    function getPendingApprovalsCount(address consequence_) external view returns(uint count_) {
        Consequence consequence = Consequence(consequence_);
        count_ = consequence.getPendingApprovalsCount();
    }

    function getPendingApproval(address consequence_, uint index_) external view returns(address approval_, uint version_, uint timestamp_) {
        Consequence consequence = Consequence(consequence_);
        approval_ = consequence.getPendingApprovalConsequence(index_);
        version_ = consequence.getPendingApprovalVersion(index_);
        timestamp_ = consequence.getPendingApprovalTimestamp(index_);
    }

    // Setters

    function addDecryptionKey(address consequence_, uint version_, address address_, bytes32 encryptedKey_) external {
        Consequence consequence = Consequence(consequence_);
        require(msg.sender == consequence.getVersionAuthor(version_), "403");
        consequence.setDecryptionKey(version_, address_, encryptedKey_);
    }

    function removeDecryptionKey(address consequence_, uint version_, address address_) external {
        Consequence consequence = Consequence(consequence_);
        require(msg.sender == consequence.getVersionAuthor(version_), "403");
        consequence.setDecryptionKey(version_, address_, bytes32(0));
    }

    function addVersion(address consequence_, string memory title_, string memory content_, bytes32 pubKeyFirst_, bytes32 pubKeySecond_, bytes32 name_) external checkConsequenceAccess(Consequence(consequence_)) { 
        // Check if the author needs to be changed
        checkAuthorOverdue(Consequence(consequence_));
        getConsequenceDeployerApp().addVersion(consequence_, title_, content_, msg.sender);
        Citizens citizens = getCitizensApp();
        citizens.updatePublicKey(msg.sender, pubKeyFirst_, pubKeySecond_);
        citizens.updateName(msg.sender, name_);
    }

    function addConsequence(address parent_, string memory title_, string memory content_, Alexandria.ConsequenceType consequenceType_, bytes32 pubKeyFirst_, bytes32 pubKeySecond_, bytes32 name_) external checkConsequenceAccess(Consequence(parent_)) {
        // Check if the parent author needs to be changed
        checkAuthorOverdue(Consequence(parent_));
        require(Consequence(parent_).getPendingApproverCount(1) == 0, "403");
        getConsequenceDeployerApp().addConsequence(parent_, title_, content_, consequenceType_, msg.sender);
        Citizens citizens = getCitizensApp();
        citizens.updatePublicKey(msg.sender, pubKeyFirst_, pubKeySecond_);
        citizens.updateName(msg.sender, name_);
    }

    // Must submit which consequence the user is proposing to approve on behalf of
    function approve(address consequence_, uint version_, address onBehalf_) external consequenceApproval(Consequence(consequence_), version_, onBehalf_) {
        Consequence consequence = Consequence(consequence_);
        // Remove approver from the pending list
        consequence.removePendingApprover(version_, onBehalf_); 
        
        // Check whether coauthor needs adding to the list and whether the inheritor needs changing
        if (consequence.getPendingApproverCount(version_) == 0) {
            address coauthor = consequence.getVersionAuthor(version_);
            bool alreadyCoAuthor = (coauthor == consequence.author());
            uint i = 0;
            while (!alreadyCoAuthor && i < consequence.getCoAuthorsCount()) {
                if (coauthor == consequence.coAuthors(i)) {
                   alreadyCoAuthor = true;
                }
                i++;
            }
            if (!alreadyCoAuthor) {
                consequence.addCoAuthor(coauthor);
            }
            // If it's a new consequence then add it as a child of its parent
            if (version_ == 1) {
                Consequence(consequence.parent()).addChild(consequence_);
            }
        }
        Consequence(onBehalf_).removeConsequenceToApprove(address(consequence_), version_);
    }

    // Must submit which consequence the user is proposing to approve on behalf of
    function reject(address consequence_, uint version_, address onBehalf_) external consequenceApproval(Consequence(consequence_), version_, onBehalf_) {
        Consequence consequence = Consequence(consequence_);
        // Remove all approvers
        for (uint i = 0; i < consequence.getPendingApproverCount(version_); i++) {
            Consequence(consequence.getPendingApprover(version_, i)).removeConsequenceToApprove(consequence_, version_);
        }
        for (uint i = 0; i < consequence.getPendingApproverCount(version_); i++) {
            consequence.removePendingApprover(version_, onBehalf_);
        }
        // Delete the consequence or set the rejected flag for the version
        if (version_ == 1) {
            consequence.destroy();
        }
        else {
            consequence.setRejected(version_, true);
            consequence.setVersionAuthor(version_, address(0));
            consequence.setTitle(version_, "");
            consequence.setContent(version_, "");
        }
    }

    function setInheritor(address consequence_, address inheritor_, bytes32 pubKeyFirst_, bytes32 pubKeySecond_, bytes32 name_) external {
        // Check if the author needs to be changed
        Consequence consequence = Consequence(consequence_);
        require(msg.sender == consequence.author(), "403");
        if (!checkAuthorOverdue(Consequence(consequence_))) {
            Citizens citizens = getCitizensApp();
            require(citizens.getName(inheritor_) == bytes32(0) || citizens.getName(inheritor_) == name_, "name");
            (bytes32 first_, bytes32 second_) = citizens.getPublicKey(inheritor_);
            require(first_ == bytes32(0) || (first_ == pubKeyFirst_ && second_ == pubKeySecond_), "key");
            consequence.setInheritor(inheritor_);
            citizens.updatePublicKey(inheritor_, pubKeyFirst_, pubKeySecond_);
            citizens.updateName(inheritor_, name_);
        }
    } 

    function editTitle(address consequence_, uint version_, string memory title_) external {
        Consequence consequence = Consequence(consequence_);
        require(msg.sender == consequence.getVersionAuthor(version_) && !consequence.isRejected(version_) && consequence.getPendingApproverCount(version_) == consequence.getOriginalApproverCount(version_), "403");
        consequence.setTitle(version_, title_);
    }

    function editContent(address consequence_, uint version_, string memory content_) external {
        Consequence consequence = Consequence(consequence_);
        require(msg.sender == consequence.getVersionAuthor(version_) && !consequence.isRejected(version_) && consequence.getPendingApproverCount(version_) == consequence.getOriginalApproverCount(version_), "403");
        consequence.setContent(version_, content_);
    }

    function deleteConsequence(address consequence_) external {
        Consequence consequence = Consequence(consequence_);
        require(msg.sender == consequence.author(), "403");
        deleteDescendants(consequence_);
        if (consequence_ != Eniko(eniko).getPurpose()) {
            Consequence(getParentSafe(consequence_)).removeChild(consequence_);
        }
        consequence.destroy();
    }

    // External Functions Limited to Ballot Functions

    function resetMissedVotes(address consequence_) external ballotFunctionsOnly {
        Consequence(consequence_).setMissedBallotCount(0);
    }

    function missedVote(address consequence_) external ballotFunctionsOnly {
        Consequence(consequence_).incrementMissedBallotCount();
    }
    
    // Internal Functions
    
    function deleteDescendants(address consequence_) internal {
        for (uint i; i < Consequence(consequence_).getChildrenCount(); i++) {
            deleteDescendants(Consequence(consequence_).children(i));
            Consequence(Consequence(consequence_).children(i)).destroy();
        }
    }

    function checkAuthorOverdue(Consequence consequence_) internal returns (bool overdue_){
        overdue_ = false;
        // Check for approvals that are over 30 days old
        uint pendingApprovalsCount = consequence_.getPendingApprovalsCount();
        uint i = 0;
        while (!overdue_ && i < pendingApprovalsCount) {
            if (consequence_.getPendingApprovalTimestamp(i) + 30 days < block.timestamp) {
                overdue_ = true;
            }
            i++;
        }
        // Check that the consequence has not skipped more than 5 votes
        if (!overdue_ && consequence_.missedBallotCount() > 5) {
            overdue_ = true;
        }
        // If overdue then decease the author
        if (overdue_) {
            address inheritor = address(0x00);
            // If the inheritor has been manually set then use it
            if (consequence_.inheritor() != address(0x00)) {
                inheritor = consequence_.inheritor();
            }
            // Otherwise if there is a coauthor then use that
            else if (consequence_.getCoAuthorsCount() > 0) {
                inheritor = consequence_.coAuthors(0);
            }
            // Otherwise if there is a child from a different author which has not been rejected and is not pending approval use that
            i = 0;
            while (inheritor == address(0x00) && i < consequence_.getChildrenCount()) {
                address child = consequence_.children(i);
                if (child != consequence_.author() && !Consequence(child).isRejected(1) && Consequence(child).getPendingApproverCount(1) == 0) {
                    inheritor = Consequence(child).author();
                }
                i++;
            }
            // Otherwise search back up the tree for an inheritor
            address parent = getParentSafe(address(consequence_));
            while (inheritor == address(0x00) && parent != eniko) {
                if(Consequence(parent).author() != consequence_.author()) {
                    inheritor = Consequence(parent).author();
                }
                parent = getParentSafe(parent);
            }
            // If we have found somebody to inherit it then pass it to them
            if (inheritor != address(0x00)) {
                consequence_.setAuthor(inheritor);
                consequence_.removeCoAuthor(inheritor);
                consequence_.setInheritor(address(0x00));
                for (uint j = 0; j < pendingApprovalsCount; j++) {
                    consequence_.setPendingApprovalTimestamp(j, block.timestamp);
                }
                consequence_.setMissedBallotCount(0);
            }
        }
    }

    // Check access to a specific version of a consequence
    function correctVersionNumber(Consequence consequence_, uint version_) internal view returns(uint correctVersion_) {
        // If the user specified an invalid version then give them the last approved version (this will return 0 if there are no versions approved)
        if (version_ >= consequence_.getVersionCount() || version_ == 0) {
            correctVersion_ = getLastApprovedVersion(consequence_);
        }
        else {
            correctVersion_ = version_;
        }
    }

    function getLastApprovedVersion(Consequence consequence_) internal view returns(uint version_) {
        version_ = consequence_.getVersionCount()-1;
        while (version_ > 0 && (consequence_.isRejected(version_) || consequence_.getPendingApproverCount(version_) > 0)) {
            version_--;
        }
    }
  
    function checkPendingApprover(Consequence consequence_, uint version_, address approver_) internal view returns(bool isPendingApprover_) {
        isPendingApprover_ = false;
        uint i = 0;
        while (!isPendingApprover_ && i < consequence_.getPendingApproverCount(version_)) {
            if (consequence_.getPendingApprover(version_, i) == approver_) {
                isPendingApprover_ = true;
            }
            i++;
        }
    }

    function hasAccess(Consequence consequence_, address user_) internal view returns(bool userAllowed) {  
        userAllowed = false;
        // Anybody is allowed if it is a public consequence and the first version has been approved, and the author and BallotFunctions are always allowed
        if (!consequence_.isRejected(1) && ((consequence_.consequenceType() == Alexandria.ConsequenceType.Public && consequence_.getPendingApproverCount(1) == 0) || user_ == consequence_.author())) {
            userAllowed = true;
        }
    }

    function getParentSafe(address consequence_) internal view returns(address parent_) {
        parent_ = Consequence(consequence_).parent();
        if (parent_ == eniko) {
            // If the parent is Eniko then this should be the purpose
            if (Eniko(eniko).getPurpose() != consequence_) {
                // If not then search through the whole tree for its parent
                parent_ = findParent(Consequence(Eniko(eniko).getPurpose()), consequence_, true);
            }
        }
        else {
            // Otherwise it should be a recognised child of the parent
            if (findParent(Consequence(parent_), consequence_, false) == address(0x00)) {
                // If not then search through the whole tree for its parent
                parent_ = findParent(Consequence(Eniko(eniko).getPurpose()), consequence_, true);
            }
        }
    }

    function findParent(Consequence ancestor_, address child_, bool recursive_) internal view returns(address parent_) {  
        parent_ = address(0x00);
        uint childCount = ancestor_.getChildrenCount();
        uint i = 0;
        while(parent_ == address(0x00) && i < childCount) {
            if (ancestor_.children(i) == child_) {
                parent_ = address(ancestor_);
            }
            else {
                if (recursive_) {
                    parent_ = findParent(Consequence(ancestor_.children(i)), child_, true);
                }
            }
            i++;
        }
    }

    // Eniko App Retrievers

    function getConsequenceDeployerApp() internal view returns (ConsequenceDeployer app_) {
        app_ = ConsequenceDeployer(Eniko(eniko).getAppAddress(5));
    }

    function getCitizensApp() internal view returns (Citizens app_) {
        app_ = Citizens(Eniko(eniko).getAppAddress(11));
    }
}