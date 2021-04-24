// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;

import './Eniko.sol';

contract Citizens is EnikoApp {
    mapping(address => bytes32) private first;           // The first half of the public key corresponding to the address
    mapping(address => bytes32) private second;          // The second half of the public key corresponding to the address
    mapping(address => bytes32) private name;            // A friendly name for the citizen

    constructor(address payable eniko_) {
        eniko = eniko_;
    }

    modifier limitedAccess {
        // Only Allow Conseqeunce Functions and Citizen Functions
        require(msg.sender == Eniko(eniko).getAppAddress(4) || msg.sender == Eniko(eniko).getAppAddress(10), "403");
        _;
    }

    function getPublicKey(address citizen_) external view returns(bytes32 first_, bytes32 second_) {
        first_ = first[citizen_];
        second_ = second[citizen_];
    }

    function getName(address citizen_) external view returns(bytes32 name_) {
        name_ = name[citizen_];
    }

    function updatePublicKey(address citizen_, bytes32 first_, bytes32 second_) external limitedAccess {
        first[citizen_] = first_;
        second[citizen_] = second_;
    }

    function updateName(address citizen_, bytes32 name_) external limitedAccess {
        name[citizen_] = name_;
    }


}