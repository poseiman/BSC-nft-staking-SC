// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interface/IUSDT.sol";

contract NFT_Staking is ERC721Enumerable, Ownable, ReentrancyGuard {
    // ---------------- Events definitions ----------------

    event UserStakeNFT(address user, uint256[] tokenList);
    event UserUnstakeNFT(address user, uint256 tokenId);
    event UserClaimed(address user, uint256 tokenId, uint256 amount);

    // ---------------- Mapping definitions ----------------

    mapping(address => mapping(uint256 => Stake)) StakeInfo;
    mapping(address => uint256) StakeCounts;

    // ---------------- Modifier ----------------

    // ---------------- Struct ----------------

    struct Stake {
        uint256 tokenId;
        uint256 stakedTime;
    }

    // ---------------- Variables ----------------

    uint256 public period;
    IUSDT immutable USDT;
    string baseUri;

    // ---------------- Constructor ----------------

    constructor(
        string memory _name,
        string memory _symbol,
        address _USDT,
        string memory _baseUri,
        uint256 _period
    ) payable ERC721(_name, _symbol) Ownable(_msgSender()) {
        USDT = IUSDT(_USDT);
        baseUri = _baseUri;
        period = _period;
    }

    // ---------------- User functions ----------------

    function stakeNFT(uint256[] calldata _tokenList) external nonReentrant {
        for (uint256 idx = 0; idx < _tokenList.length; idx++)
            require(
                _ownerOf(_tokenList[idx]) == msg.sender,
                "You are not a owner this token"
            );

        require(
            isApprovedForAll(msg.sender, address(this)),
            "You have not approve yet"
        );

        for (uint256 idx = 0; idx < _tokenList.length; idx++) {
            transferFrom(msg.sender, address(this), _tokenList[idx]);

            StakeInfo[msg.sender][StakeCounts[msg.sender]++] = Stake({
                tokenId: _tokenList[idx],
                stakedTime: block.timestamp
            });
        }

        emit UserStakeNFT(msg.sender, _tokenList);
    }

    function unStakeNFT(uint256 _tokenId) external nonReentrant {
        uint256 idx = checkExist(getStakedTokenIds(msg.sender), _tokenId);

        uint256 reward = claimableAmount(msg.sender, _tokenId);

        StakeInfo[msg.sender][idx] = StakeInfo[msg.sender][
            --StakeCounts[msg.sender]
        ];

        USDT.distributeReward(msg.sender, reward);
        _safeTransfer(address(this), msg.sender, _tokenId);

        emit UserUnstakeNFT(msg.sender, _tokenId);
    }

    function claim(uint256 _tokenId) external nonReentrant {
        uint256 idx = checkExist(getStakedTokenIds(msg.sender), _tokenId);

        uint256 reward = claimableAmount(msg.sender, _tokenId);
        StakeInfo[msg.sender][idx].stakedTime = block.timestamp;
        USDT.distributeReward(msg.sender, reward);

        emit UserClaimed(msg.sender, _tokenId, reward);
    }

    // ---------------- Virtual functions ----------------

    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }

    // ---------------- Private functions ----------------

    function checkExist(
        uint256[] memory _array,
        uint256 _item
    ) private pure returns (uint256) {
        for (uint256 idx = 0; idx < _array.length; idx++)
            if (_array[idx] == _item) return idx;
        revert("User did not stake this nft");
    }

    // ---------------- Public functions ----------------

    function getStakedNFTList(
        address _user
    ) external view returns (Stake[] memory stakedList) {
        stakedList = new Stake[](StakeCounts[_user]);
        for (uint256 idx = 0; idx < StakeCounts[_user]; idx++)
            stakedList[idx] = StakeInfo[_user][idx];
    }

    function getStakedTokenIds(
        address _user
    ) public view returns (uint256[] memory stakedList) {
        stakedList = new uint256[](StakeCounts[_user]);
        for (uint256 idx = 0; idx < StakeCounts[_user]; idx++)
            stakedList[idx] = StakeInfo[_user][idx].tokenId;
    }

    function claimableAmount(
        address _user,
        uint256 _tokenId
    ) public view returns (uint256 reward) {
        uint256 idx = checkExist(getStakedTokenIds(_user), _tokenId);
        uint256 stakedTime = StakeInfo[_user][idx].stakedTime;
        reward = (block.timestamp - stakedTime) / period;
    }

    function userOwnedTokens(
        address _user
    ) public view returns (uint256[] memory tokenList) {
        uint256 count = balanceOf(_user);
        tokenList = new uint256[](count);
        for (uint256 idx = 0; idx < count; idx++) {
            tokenList[idx] = tokenOfOwnerByIndex(_user, idx);
        }
    }

    // ---------------- Owner functions ----------------

    function setPeriod(uint256 _period) external onlyOwner {
        period = _period;
    }

    function setBaseURI(string memory _baseUri) external onlyOwner {
        baseUri = _baseUri;
    }

    function provideNFT(address _user) external onlyOwner {
        _mint(_user, totalSupply());
    }
}
