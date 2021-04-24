// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;

import './Eniko.sol';

contract MessagingFramework is EnikoApp {

    constructor(address payable eniko_) {
        eniko = eniko_;
    }
}