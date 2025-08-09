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

        address owner = 0x9a56fFd72F4B526c523C733F1F74197A51c495E1;

        MockERC20 usdc = MockERC20(address(0x61595c6EeF6ea1F6413dE383106C957dE524197c));
        usdc.mint(owner, 1000 ether);

        vm.stopBroadcast();
    }
}
