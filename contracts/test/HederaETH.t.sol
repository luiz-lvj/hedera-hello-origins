// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {HederaETF} from "../src/HederaETF.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";
import {Vault} from "../src/Vault.sol";

import {HederaResponseCodes} from "../src/hedera/HederaResponseCodes.sol";

contract HederaETFTest is Test {
    MockERC20 public usdc;
    Vault public vaultUsdY;
    HederaETF public hederaETF;

    address public owner = makeAddr("owner");

    address public user = makeAddr("user");

    address public nonRegisteredUser = makeAddr("nonRegisteredUser");

    function setUp() public {
        usdc = new MockERC20("USDC", "USDC");
        vaultUsdY = new Vault(usdc, "USDY", "USDY");

        hederaETF = new HederaETF(address(this), address(vaultUsdY), address(usdc));

        usdc.mint(user, 1000 ether);
    }

    function test_registerInvestor() public {
        hederaETF.registerInvestor();

        assertTrue(hederaETF.isUserRegistered(user));
    }

    function test_invest() public {
        hederaETF.registerInvestor();
        hederaETF.invest(1000 ether);

        assertTrue(hederaETF.isUserRegistered(user));
    }

    function test_desinvest() public {
        hederaETF.registerInvestor();
        hederaETF.invest(1000 ether);
        hederaETF.desinvest(1000 ether);
    }

    function test_revertInvestIfNotRegistered() public {
        vm.expectRevert("Not a registered investor");
        hederaETF.invest(1000 ether);
    }

    function test_revertDesinvestIfNotRegistered() public {
        vm.expectRevert("Not a registered investor");
        hederaETF.desinvest(1000 ether);
    }
}
