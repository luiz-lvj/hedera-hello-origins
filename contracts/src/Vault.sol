// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC4626} from "openzeppelin/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

contract Vault is ERC4626 {
    constructor(IERC20 asset, string memory name, string memory symbol) ERC4626(asset) ERC20(name, symbol) {}
}
