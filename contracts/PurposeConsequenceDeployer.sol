// Set this contract as the ConsequenceCreator in Eniko
// Use it to create the principle
// Set the principle in Eniko
// Destroy this contract
// Set the real ConsequenceCreator in Eniko

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;

import './Alexandria.sol';
import './Eniko.sol';
import './Consequence.sol';


contract PurposeConsequenceDeployer is EnikoApp {
    
    using Alexandria for Alexandria.ConsequenceType;
    using Alexandria for Alexandria.ConsequenceVersion;

    address purposeAddress;

    // Constructor
    constructor(address payable eniko_) {
        eniko = eniko_;
    }

    function createPurpose(string memory title_, string memory content_) external returns(address purpose_) {
        require(msg.sender == Eniko(eniko).getFounder(), "403");
        require(Eniko(eniko).getPurpose() == address(0x00), "Purpose already set");
        require(bytes(title_).length < 64, "Title must be less than 64 bytes");
        Consequence purpose = new Consequence(eniko);
        purposeAddress = address(purpose);
        // Set variables
        purpose.setAuthor(Eniko(eniko).getFounder());
        purpose.setParent(eniko);
        purpose.setType(Alexandria.ConsequenceType.Public);
        purpose.setInheritor(address(0x00));
        purpose.setMissedBallotCount(0);
        purpose.addVersion(title_, content_, Eniko(eniko).getFounder(), false);
        purpose_ = address(purpose);
    }

    function getPurposeAddress() external view returns (address purposeAddress_) {
        purposeAddress_ = purposeAddress;
    }

}