// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.5;

import './Eniko.sol';
import './Citizens.sol';

contract CitizenFunctions is EnikoApp {

    // Constructor
    constructor(address payable eniko_) {
        eniko = eniko_;
    }

    function getPublicKey(address citizen_) external view returns(bytes32 first_, bytes32 second_) {
        (first_, second_) = getCitizensApp().getPublicKey(citizen_);
    }

    function getCitizenName(address citizen_) external view returns(bytes32 name_) {
        name_ = getCitizensApp().getName(citizen_);
    }

    function getCitizensApp() internal view returns (Citizens app_) {
        app_ = Citizens(Eniko(eniko).getAppAddress(11));
    }

    function setPublicKey(bytes32 first_, bytes32 second_) external  {
        getCitizensApp().updatePublicKey(msg.sender, first_, second_);
    }

    function setCitizenName(bytes32 name_) external  {
        getCitizensApp().updateName(msg.sender, name_);
    }

}