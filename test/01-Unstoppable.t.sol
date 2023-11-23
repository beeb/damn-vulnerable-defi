// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { BaseFixture } from "test/utils/Fixtures.sol";

import { DamnValuableToken } from "src/DamnValuableToken.sol";
import { ReceiverUnstoppable } from "src/01-Unstoppable/ReceiverUnstoppable.sol";
import { UnstoppableVault } from "src/01-Unstoppable/UnstoppableVault.sol";

contract TestUnstoppable is BaseFixture {
    uint256 public constant TOKENS_IN_VAULT = 1_000_000 ether;
    uint256 public constant INITIAL_PLAYER_TOKEN_BALANCE = 10 ether;

    DamnValuableToken token;
    UnstoppableVault vault;
    ReceiverUnstoppable receiver;

    function setUp() public {
        vm.startPrank(deployer);
        token = new DamnValuableToken();
        vault = new UnstoppableVault(token, deployer,deployer);
        token.approve(address(vault), TOKENS_IN_VAULT);
        vault.deposit(TOKENS_IN_VAULT, deployer);
        token.transfer(player, INITIAL_PLAYER_TOKEN_BALANCE);
        vm.stopPrank();
        vm.prank(someUser);
        receiver = new ReceiverUnstoppable(address(vault));
    }

    function checkSuccess() internal {
        vm.expectRevert();
        vm.prank(someUser);
        receiver.executeFlashLoan(100 ether);
    }

    function test_setUp() public {
        vm.prank(someUser);
        receiver.executeFlashLoan(100 ether); // check that flashloans work
        assertEq(address(vault.asset()), address(token));
        assertEq(token.balanceOf(address(vault)), TOKENS_IN_VAULT);
        assertEq(vault.totalAssets(), TOKENS_IN_VAULT);
        assertEq(vault.totalSupply(), TOKENS_IN_VAULT);
        assertEq(vault.maxFlashLoan(address(token)), TOKENS_IN_VAULT);
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT - 1), 0);
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT), 50_000 ether);
        assertEq(token.balanceOf(player), INITIAL_PLAYER_TOKEN_BALANCE);
    }

    function test() public {
        // Sending tokens without minting the corresponding vault shares makes the vault revert with `InvalidBalance()`
        vm.prank(player);
        token.transfer(address(vault), 1);

        checkSuccess();
    }
}
