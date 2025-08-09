// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./HederaTokenService.sol";
//import "./ExpiryHelper.sol";
import "./KeyHelper.sol";
//import "./FeeHelper.sol";

contract HTSContract is HederaTokenService, KeyHelper {
    bool finiteTotalSupplyType = true;

    event CreatedToken(address tokenAddress);

    function createFungibleTokenPublic(
        string memory _name,
        string memory _symbol,
        string memory _memo,
        int64 _initialTotalSupply,
        int64 _maxSupply,
        int32 _decimals,
        bool _freezeDefaultStatus,
        address _treasury,
        IHederaTokenService.TokenKey[] memory _keys
    ) public payable returns (int256 responseCode, address tokenAddress) {
        IHederaTokenService.Expiry memory expiry = IHederaTokenService.Expiry(0, _treasury, 8000000);

        IHederaTokenService.HederaToken memory token = IHederaTokenService.HederaToken(
            _name, _symbol, _treasury, _memo, finiteTotalSupplyType, _maxSupply, _freezeDefaultStatus, _keys, expiry
        );

        (int256 responseCode, address tokenAddress) =
            HederaTokenService.createFungibleToken(token, _initialTotalSupply, _decimals);

        if (responseCode != HederaResponseCodes.SUCCESS) {
            revert();
        }


        emit CreatedToken(tokenAddress);
    }
}
