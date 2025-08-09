// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
pragma experimental ABIEncoderV2;

import "./hedera/HederaTokenService.sol";
import "./hedera/IHederaTokenService.sol";
import "./hedera/KeyHelper.sol";

import {IERC4626} from "openzeppelin/interfaces/IERC4626.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

import {HTSContract} from "./hedera/HTSContract.sol";

contract HederaETF is HederaTokenService, KeyHelper, Ownable {
    // Hedera token address
    address private _tokenAddress;

    // ERC4626 tokens
    IERC4626 private _vault; // USDY
    IERC20 private _underlyingToken; // USDC

    event TokenCreated(address tokenAddress);
    event InvestorRegistered(address investor);
    event InvestimentMade(address investor, uint256 amount, uint256 shares);
    event DesinvestimentMade(address investor, uint256 assets, uint256 shares);

    modifier onlyRegisteredInvestor() {
        (int64 responseCode, bool kycGranted) = isKyc(_tokenAddress, msg.sender);
        require(responseCode == HederaResponseCodes.SUCCESS && kycGranted, "Not a registered investor");
        _;
    }

    constructor(address owner_, address vaultAddress_, address underlyingTokenAddress_) Ownable(owner_) payable{
        _vault = IERC4626(vaultAddress_);
        _underlyingToken = IERC20(underlyingTokenAddress_);
        _initializeToken();
    }

    function initializeToken(address tokenAddress_) public onlyOwner {
        _tokenAddress = tokenAddress_;
    }

    function _initializeToken() internal {
        IHederaTokenService.HederaToken memory token;
        token.name = "HETF - USDY";
        token.symbol = "HETF-USDY";
        token.memo = "HETF - USDY";
        token.treasury = address(this);

        IHederaTokenService.TokenKey[] memory keys = new IHederaTokenService.TokenKey[](1);

        // Supply key - for minting/burning
        keys[0] = getSingleKey(KeyType.SUPPLY, KeyValueType.CONTRACT_ID, address(this));

        // // Pause key
        // keys[1] = getSingleKey(KeyType.PAUSE, KeyValueType.CONTRACT_ID, address(this));

        // // Freeze key
        // keys[2] = getSingleKey(KeyType.FREEZE, KeyValueType.CONTRACT_ID, address(this));

        // // Wipe key
        // keys[3] = getSingleKey(KeyType.WIPE, KeyValueType.CONTRACT_ID, address(this));

        // // Delete key
        // keys[4] = getSingleKey(KeyType.ADMIN, KeyValueType.CONTRACT_ID, address(this));

        token.tokenKeys = keys;

        // (int256 responseCode, address createdTokenAddress) = createFungibleToken(token, 0, 6);

        (int256 responseCode, address createdTokenAddress) = HTSContract(0x000000000000000000000000000000000063b876).
            createFungibleTokenPublic(token.name, token.symbol, token.memo, 0, 1000000000000, 6, false, address(this), keys);

        //require(responseCode == HederaResponseCodes.SUCCESS, "Failed to create token");

        _tokenAddress = createdTokenAddress;
        emit TokenCreated(_tokenAddress);
    }

    

    function registerInvestorSelf() public {
        int256 responseCode = grantTokenKyc(_tokenAddress, msg.sender);

        require(responseCode == HederaResponseCodes.SUCCESS, "Failed to grant KYC");
        emit InvestorRegistered(msg.sender);
    }

    function registerInvestor(address investor) public onlyOwner {
        int256 responseCode = grantTokenKyc(_tokenAddress, investor);
        require(responseCode == HederaResponseCodes.SUCCESS, "Failed to grant KYC");
        emit InvestorRegistered(investor);
    }

    function invest(uint256 amount) public onlyRegisteredInvestor {
        _underlyingToken.transferFrom(msg.sender, address(this), amount);
        uint256 shares = _vault.deposit(amount, address(this));

        bytes[] memory metadata = new bytes[](0);

        (int256 responseCode,,) = mintToken(_tokenAddress, int64(uint64(shares)), metadata);

        require(responseCode == HederaResponseCodes.SUCCESS, "Failed to mint token");
        emit InvestimentMade(msg.sender, amount, shares);
    }

    function desinvest(uint256 assets) public onlyRegisteredInvestor {
        uint256 shares = _vault.withdraw(assets, msg.sender, msg.sender);

        int64[] memory metadata = new int64[](0);

        (int256 responseCode,) = burnToken(_tokenAddress, int64(uint64(shares)), metadata);

        require(responseCode == HederaResponseCodes.SUCCESS, "Failed to burn token");
        emit DesinvestimentMade(msg.sender, assets, shares);
    }

    // View functions
    function getTokenAddress() public view returns (address) {
        return _tokenAddress;
    }

    function isUserRegistered(address user) public returns (bool) {
        (int64 responseCode, bool kycGranted) = isKyc(_tokenAddress, user);
        return responseCode == HederaResponseCodes.SUCCESS && kycGranted;
    }
}
