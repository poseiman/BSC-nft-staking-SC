// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract USDT is ERC20, Ownable, ReentrancyGuard {
    constructor(
        string memory _name,
        string memory _symbol
    ) payable ERC20(_name, _symbol) Ownable(_msgSender()) {}

    function distributeReward(
        address _user,
        uint256 _amount
    ) external onlyOwner {
        _mint(_user, _amount);
    }
}
