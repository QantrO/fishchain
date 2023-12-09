// SPDX-License-Identifier: MIT
// A modified version of the SimpleStorage.sol contract from quorum-dev-quickstart
pragma solidity ^0.8.10;

contract OnboardingDetails {
    string public ipAddress;
    string public publicKey;

    event MemberDetails(address _setter, string _ipAddress, string _publicKey);

    constructor(string memory initIp, string memory initPubKey) {
        ipAddress = initIp;
        publicKey = initPubKey;
        emit MemberDetails(msg.sender, initIp, initPubKey);
    }

    function getMemberDetails()
        public
        view
        returns (string memory, string memory)
    {
        return (ipAddress, publicKey);
    }

    function set(string memory newIp, string memory newPubKey) public {
        ipAddress = newIp;
        publicKey = newPubKey;
        emit MemberDetails(address(this), newIp, newPubKey);
    }
}
