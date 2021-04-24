// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.5;

library Alexandria {
    enum ConsequenceType {Public, Private}
    

    struct ConsequenceVersion {
        string title;                                   // The title of the consequence
        string content;                                 // The content of the consequence
        address[] pendingApprovers;                     // An array of pending approvers
        mapping (address => bytes32) encryptedKeys;     // A mapping of pending approvers
        address author;                                 // The author who submitted the version
        uint originalApproverCount;                     // The number of approvers originally set
        bool rejected;                                  // Flag that a version has been rejected
    }

    struct VoterDetails {
        address choice;
        address[] followers;
        bytes32 title;
        bool exists;
        uint voteCount;
        bool tookAction;
    }
}