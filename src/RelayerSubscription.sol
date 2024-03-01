// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RelayerSubscription is Ownable {
    uint256 public subscriptionPrice;

    uint256 immutable SUB_DURATION = 30 days;

    mapping(string => uint256) subscriptionInfos; // user ID to subscription expiry timestamp

    event NewSubscription(string indexed userId, uint256 indexed expiry);

    constructor(uint256 _subscriptionPrice) Ownable(msg.sender) {
        subscriptionPrice = _subscriptionPrice;
    }

    function subscribe(string calldata _userId) external payable {
        require(msg.value == subscriptionPrice, "Invalid amount sent");
        require(!isSubscribed(_userId), "User is already subscribed");
        uint256 expiry = block.timestamp + SUB_DURATION;
        subscriptionInfos[_userId] = expiry;
        emit NewSubscription(_userId, expiry);
    }

    function isSubscribed(string calldata _userId) public view returns (bool) {
        uint256 subInfo = subscriptionInfos[_userId];
        return subInfo < block.timestamp;
    }

    function setSubscriptionPrice(uint256 _newPrice) external onlyOwner {
        subscriptionPrice = _newPrice;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "transfer failed");
    }
}