// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;

import './Eniko.sol';
import './Ballot.sol';

contract BallotDeployer is EnikoApp {

    modifier limitedAccess {
        require(msg.sender == Eniko(eniko).getAppAddress(7), "403");
        _;
    }
    
    // Constructor
    constructor(address payable eniko_) {
        eniko = eniko_;
    }

    function deployBallot() external limitedAccess returns(Ballot ballot_) { 
        ballot_ = new Ballot(eniko);
    }
}