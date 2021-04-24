// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;

import './Eniko.sol';

contract BallotList is EnikoApp {
    address[] private list;         // A list of all ballots

    constructor(address payable eniko_) {
        eniko = eniko_;
    }

    modifier ballotFunctionsOnly {
        require(msg.sender == Eniko(eniko).getAppAddress(7), "403");
        _;
    }
    
    function getBallots() external view returns(address[] memory list_) {
        list_ = list;
    }
    
    function addBallot(address ballot_) external ballotFunctionsOnly {
        list.push(ballot_);
    }
    
    function removeBallot(address ballot_) external ballotFunctionsOnly {
        uint j = 0;
        for (uint i = 0; i < list.length; i++) {
            if (list[i] == ballot_) {
                j++;
            }
            else {
                if (j>0) {
                    list[i-j] = list[i];
                }
            }
        }
        for (uint i = 0; i < j; i++) {
            list.pop();
        }
    }

}
