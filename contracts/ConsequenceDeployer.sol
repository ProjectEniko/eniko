// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;

import './Eniko.sol';
import './Consequence.sol';
import './ConsequenceFunctions.sol';

contract ConsequenceDeployer is EnikoApp {

    modifier limitedAccess {
        require(msg.sender == Eniko(eniko).getAppAddress(4), "403");
        _;
    }
    
    // Constructor
    constructor(address payable eniko_) {
        eniko = eniko_;
    }

    function getEniko() external view returns(address eniko_) {
        eniko_ = eniko;
    }

    function addVersion(address consequence_, string memory title_, string memory content_, address author_) external limitedAccess { 
        require(bytes(title_).length < 64, "Title must be less than 64 bytes");
        ConsequenceFunctions consequenceFunctions = getConsequenceFunctionsApp();
        Consequence consequence = Consequence(consequence_);
        // Create the version and add the consequecne itself as the first approver
        uint version = consequence.addVersion(title_, content_, author_, false);
        consequence.addPendingApprover(version, consequence_);
        consequence.addNewConsequenceToApprove(consequence_, version, block.timestamp);
        // Search up the tree to find a second approver
        address secondApproverConsequence = consequenceFunctions.getParent(consequence_);
        while (secondApproverConsequence != eniko && Consequence(secondApproverConsequence).author() == consequence.author()) {
            secondApproverConsequence = consequenceFunctions.getParent(secondApproverConsequence);
        }
        // If we only quit because we reached the eniko then no need to add a second approver
        if (secondApproverConsequence != eniko) {
            consequence.addPendingApprover(version, secondApproverConsequence);
            Consequence(secondApproverConsequence).addNewConsequenceToApprove(consequence_, version, block.timestamp);
            consequence.setOriginalApproverCount(version, 2);
        }
        else {
            consequence.setOriginalApproverCount(version, 1);
        }
    }

    function addConsequence(address parent_, string memory title_, string memory content_, Alexandria.ConsequenceType consequenceType_, address author_) external limitedAccess {
        require(bytes(title_).length < 64, "Title must be less than 64 bytes");
        ConsequenceFunctions consequenceFunctions = getConsequenceFunctionsApp();
        
        // Create the consequence
        //Consequence newConsequence = ConsequenceDeployer(Eniko(eniko).getAppAddress(6)).deployConsequence();
        Consequence newConsequence = new Consequence(eniko);
        // Set variables
        newConsequence.setAuthor(author_);
        newConsequence.setParent(parent_);
        newConsequence.setType(consequenceType_);
        newConsequence.setInheritor(address(0x00));
        newConsequence.setMissedBallotCount(0);
        newConsequence.addVersion(title_, content_, author_, false);
        
        // Set the parent as the first pending approver
        newConsequence.addPendingApprover(1, parent_);
        Consequence(parent_).addNewConsequenceToApprove(address(newConsequence), 1, block.timestamp);
        
        // Find a second approver
        address grandparent = parent_;
        // If the new consequence author is the parent author then we need to find a grandparent with a different author
        // If the new consequence author is not the parent author then we need to find a grandparent author but this could be the new consequence author
        // So in summary the grandparent author must not be the same as the parent author
        // Search back up the tree to find a grandparent author who is not the parent author 
        while (consequenceFunctions.getParent(grandparent) != eniko && Consequence(grandparent).author() == Consequence(parent_).author()) {
            grandparent = consequenceFunctions.getParent(grandparent);
        }
        // If we quit the while loop only because Consequence(grandparent_).getParent() == eniko then make the purpose the second approver
        if (consequenceFunctions.getParent(grandparent) == eniko && Consequence(grandparent).author() == Consequence(parent_).author()) {
            address purpose = Eniko(eniko).getPurpose();
            // Only if the purpose is not already an approver
            if (purpose != parent_) {
                newConsequence.addPendingApprover(1, purpose);
                Consequence(purpose).addNewConsequenceToApprove(address(newConsequence), 1, block.timestamp);
                newConsequence.setOriginalApproverCount(1, 2);
            }
            else {
                newConsequence.setOriginalApproverCount(1, 1);
            }
        } 
        // Otherwise the grandparent which we just found becomes the second approver
        else {
            // Only if the grandparent is not already an approver
            if (grandparent != parent_) {
                newConsequence.addPendingApprover(1, grandparent);
                Consequence(grandparent).addNewConsequenceToApprove(address(newConsequence), 1, block.timestamp);
                newConsequence.setOriginalApproverCount(1, 2);
            }
            else {
                newConsequence.setOriginalApproverCount(1, 1);
            }
        }
    }

    // Eniko App Retrievers

    function getConsequenceFunctionsApp() internal view returns (ConsequenceFunctions app_) {
        app_ = ConsequenceFunctions(Eniko(eniko).getAppAddress(4));
    }

}