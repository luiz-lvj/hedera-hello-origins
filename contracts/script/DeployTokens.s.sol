// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";
import {Vault} from "../src/Vault.sol";

contract DeployTokensScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        MockERC20 usdc = new MockERC20("USDC", "USDC");
        Vault vaultUsdY = new Vault(usdc, "USDY", "USDY");

        console.log("USDC address", address(usdc));
        console.log("Vault address", address(vaultUsdY));

        address owner = 0x9a56fFd72F4B526c523C733F1F74197A51c495E1;

        usdc.mint(owner, 1000 ether);

        vm.stopBroadcast();
    }
}
