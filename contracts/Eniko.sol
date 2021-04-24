// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.5;

contract Eniko {

    address private purpose;                // The single purpose linked to this Eniko
    address private founder;                // the founder has certain proveliges until 2.2.22
    EnikoApp[] private apps;                // An array of decentralised apps hosted by Eniko

    // Fixed App Indices
    // 0 = Null - Used as a safe value
    // 1 = CitizenNeedsFunctions
    // 2 = NeedDeployer
    // 3 = SolutionDeployer
    // 4 = ConsequenceFunctions
    // 5 = ConsequenceDeployer
    // 6 = null
    // 7 = BallotFunctions
    // 8 = BallotDeployer
    // 9 = BallotList
    // 10 = CitizenFunctions
    // 11 = Citizens
    // 12 = MessagingFramework

    modifier limitedAccess {
        // From 2.2.22 all changes must come via a ballot
        if (block.timestamp > 1643760000) {
            require(msg.sender == address(apps[7]), "403");
        }
        // Otherwise the founder may also make changes
        else {
            require(msg.sender == address(apps[7]) || msg.sender == founder, "403");
        }
        _;
    }

    constructor() {
        founder = msg.sender;
        for (uint i=0; i < 13; i++) {
            apps.push();
        }
    }

    // Setters

    function setPurpose(address purpose_) external limitedAccess {
        purpose = purpose_;
    }

    function updateAppAddress(uint index_, address newAppAddress_) external limitedAccess returns(uint finalIndex_) {
        require(index_ != 0, "Null address cannot be updated");
        // Avoid gaps
        if (index_ >= apps.length) {
            finalIndex_ = apps.length;
            apps.push();
        }
        else {
            if (address(apps[index_]) != newAppAddress_ && address(apps[index_]) != address(0x00)) {
                apps[index_].destroy();
            }
            finalIndex_ = index_;
        }
        apps[finalIndex_] = EnikoApp(newAppAddress_);
    }

    // Getters
    
    function getPurpose() external view returns(address purpose_) {
        purpose_ = purpose;
    }

    function getFounder() external view returns(address founder_) {
        founder_ = founder;
    }

    function getAppAddress(uint index_) external view returns(address address_) {
        address_ = address(apps[index_]);
    }

    function getAppCount() external view returns(uint count_) {
        count_ = apps.length;
    }

    // Destruction

    function destroy() external limitedAccess {
        selfdestruct(msg.sender);
    }

    function destroyAll() external limitedAccess {
        for (uint i=0; i < apps.length; i++) {
            if (address(apps[i]) != address(0x00)) {
                apps[i].destroy();
            }
        }
        selfdestruct(msg.sender);
    }

    // Payable Functions

    receive() external payable {}
    fallback() external payable {}

}

// All apps must be EnikoApps
contract EnikoApp {

    address payable eniko;                    // The root eniko contract from which this consequence derives.

    function destroy() external {
        require(msg.sender == eniko, "403");
        selfdestruct(eniko);
    }

}
