// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";
import {Vault} from "../src/Vault.sol";
import {HederaETF} from "../src/HederaETF.sol";

contract HederaETFScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        HederaETF hederaETF = HederaETF(address(0));
        hederaETF.desinvest(500 * 10 ** 6);

        vm.stopBroadcast();
    }
}
