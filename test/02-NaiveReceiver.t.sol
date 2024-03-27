// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { BaseFixture } from "test/utils/Fixtures.sol";

import { NaiveReceiverLenderPool } from "src/02-NaiveReceiver/NaiveReceiverLenderPool.sol";
import { FlashLoanReceiver } from "src/02-NaiveReceiver/FlashLoanReceiver.sol";
import { Attack } from "src/02-NaiveReceiver/Attack.sol";

contract TestUnstoppable is BaseFixture {
    uint256 public constant ETHER_IN_POOL = 1000 ether;
    uint256 public constant ETHER_IN_RECEIVER = 10 ether;

    NaiveReceiverLenderPool pool;
    FlashLoanReceiver receiver;

    function setUp() public {
        vm.startPrank(deployer);
        pool = new NaiveReceiverLenderPool();
        sendEther(address(pool), ETHER_IN_POOL);
        receiver = new FlashLoanReceiver(address(pool));
        sendEther(address(receiver), ETHER_IN_RECEIVER);
        vm.stopPrank();
    }

    function checkSuccess() internal {
        assertEq(address(receiver).balance, 0);
        assertEq(address(pool).balance, ETHER_IN_POOL + ETHER_IN_RECEIVER);
    }

    function test_setUp() public {
        address ETH = pool.ETH();
        assertEq(address(pool).balance, ETHER_IN_POOL);
        assertEq(pool.maxFlashLoan(ETH), ETHER_IN_POOL);
        assertEq(pool.flashFee(ETH, 0), 1 ether);
        vm.expectRevert();
        vm.prank(deployer);
        receiver.onFlashLoan(deployer, ETH, ETHER_IN_RECEIVER, 1 ether, "");
        assertEq(address(receiver).balance, ETHER_IN_RECEIVER);
    }

    function test() public {
        vm.prank(player);
        new Attack(pool, receiver);

        checkSuccess();
    }
}
