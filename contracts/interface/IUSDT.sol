// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IUSDT {
    function distributeReward(address _user, uint256 _amount) external;
}
