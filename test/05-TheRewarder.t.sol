// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { BaseFixture } from "test/utils/Fixtures.sol";

import { DamnValuableToken } from "src/DamnValuableToken.sol";
import { FlashLoanerPool } from "src/05-TheRewarder/FlashLoanerPool.sol";
import { TheRewarderPool } from "src/05-TheRewarder/TheRewarderPool.sol";
import { RewardToken } from "src/05-TheRewarder/RewardToken.sol";
import { AccountingToken } from "src/05-TheRewarder/AccountingToken.sol";

contract TestSideEntrance is BaseFixture {
    uint256 public constant TOKENS_IN_LENDER_POOL = 1e6 ether;
    uint256 public constant DEPOSIT_AMOUNT = 100 ether;

    DamnValuableToken internal liquidityToken;
    FlashLoanerPool internal flashLoanPool;
    TheRewarderPool internal rewarderPool;
    RewardToken internal rewardToken;
    AccountingToken internal accountingToken;

    function setUp() public {
        vm.startPrank(deployer);
        liquidityToken = new DamnValuableToken();
        flashLoanPool = new FlashLoanerPool(address(liquidityToken));
        liquidityToken.transfer(address(flashLoanPool), TOKENS_IN_LENDER_POOL);
        rewarderPool = new TheRewarderPool(address(liquidityToken));
        rewardToken = RewardToken(rewarderPool.rewardToken());
        accountingToken = AccountingToken(rewarderPool.accountingToken());
        liquidityToken.transfer(alice, DEPOSIT_AMOUNT);
        liquidityToken.transfer(bob, DEPOSIT_AMOUNT);
        liquidityToken.transfer(charlie, DEPOSIT_AMOUNT);
        liquidityToken.transfer(david, DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(alice);
        liquidityToken.approve(address(rewarderPool), DEPOSIT_AMOUNT);
        rewarderPool.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        vm.startPrank(bob);
        liquidityToken.approve(address(rewarderPool), DEPOSIT_AMOUNT);
        rewarderPool.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        vm.startPrank(charlie);
        liquidityToken.approve(address(rewarderPool), DEPOSIT_AMOUNT);
        rewarderPool.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        vm.startPrank(david);
        liquidityToken.approve(address(rewarderPool), DEPOSIT_AMOUNT);
        rewarderPool.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();

        skip(5 days);

        vm.prank(alice);
        rewarderPool.distributeRewards();
        vm.prank(bob);
        rewarderPool.distributeRewards();
        vm.prank(charlie);
        rewarderPool.distributeRewards();
        vm.prank(david);
        rewarderPool.distributeRewards();
    }

    function checkSuccess() internal {
        assertEq(rewarderPool.roundNumber(), 3, "round number");

        vm.prank(alice);
        rewarderPool.distributeRewards();
        vm.prank(bob);
        rewarderPool.distributeRewards();
        vm.prank(charlie);
        rewarderPool.distributeRewards();
        vm.prank(david);
        rewarderPool.distributeRewards();

        assertLt(rewardToken.balanceOf(alice) - rewarderPool.REWARDS() / 4, 1e16, "alice's rewards");
        assertLt(rewardToken.balanceOf(bob) - rewarderPool.REWARDS() / 4, 1e16, "bob's rewards");
        assertLt(rewardToken.balanceOf(charlie) - rewarderPool.REWARDS() / 4, 1e16, "charlie's rewards");
        assertLt(rewardToken.balanceOf(david) - rewarderPool.REWARDS() / 4, 1e16, "david's rewards");

        assertGt(rewardToken.totalSupply(), rewarderPool.REWARDS(), "reward token total supply");
        assertGt(rewardToken.balanceOf(player), 0, "player's rewards");
        assertLt(rewarderPool.REWARDS() - rewardToken.balanceOf(player), 1e17, "rewards amount");
        assertEq(liquidityToken.balanceOf(player), 0, "player's liquidity token balance");
        assertEq(
            liquidityToken.balanceOf(address(flashLoanPool)), TOKENS_IN_LENDER_POOL, "liquidity tokens in lender pool"
        );
    }

    function test_setUp() public view {
        assertEq(accountingToken.owner(), address(rewarderPool), "accounting token owner");
        assertTrue(
            accountingToken.hasAllRoles(
                address(rewarderPool),
                accountingToken.MINTER_ROLE() | accountingToken.SNAPSHOT_ROLE() | accountingToken.BURNER_ROLE()
            )
        );

        assertEq(accountingToken.balanceOf(alice), DEPOSIT_AMOUNT, "alice's deposit amount");
        assertEq(accountingToken.balanceOf(bob), DEPOSIT_AMOUNT, "bob's deposit amount");
        assertEq(accountingToken.balanceOf(charlie), DEPOSIT_AMOUNT, "charlie's deposit amount");
        assertEq(accountingToken.balanceOf(david), DEPOSIT_AMOUNT, "david's deposit amount");

        assertEq(accountingToken.totalSupply(), 4 * DEPOSIT_AMOUNT, "accounting token total supply");
        assertEq(rewardToken.totalSupply(), rewarderPool.REWARDS(), "reward token total supply");
        assertEq(liquidityToken.balanceOf(player), 0, "player's liquidity token balance");
        assertEq(rewarderPool.roundNumber(), 2, "round number");
    }

    function test() public {
        vm.prank(player);
        // checkSuccess();
    }
}
