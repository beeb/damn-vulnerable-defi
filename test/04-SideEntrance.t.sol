// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { BaseFixture } from "test/utils/Fixtures.sol";

import { SideEntranceLenderPool } from "src/04-SideEntrance/SideEntranceLenderPool.sol";
import { Attack } from "src/04-SideEntrance/Attack.sol";

contract TestSideEntrance is BaseFixture {
    uint256 public constant ETHER_IN_POOL = 1000 ether;
    uint256 public constant PLAYER_INITIAL_ETH_BALANCE = 1 ether;

    SideEntranceLenderPool pool;

    function setUp() public {
        vm.startPrank(deployer);
        pool = new SideEntranceLenderPool();
        pool.deposit{ value: ETHER_IN_POOL }();
        vm.stopPrank();
        vm.startPrank(player);
        sendEther(deployer, player.balance - PLAYER_INITIAL_ETH_BALANCE);
        vm.stopPrank();
    }

    function checkSuccess() internal {
        assertEq(address(pool).balance, 0, "pool balance");
        assertGt(player.balance, ETHER_IN_POOL, "player balance");
    }

    function test_setUp() public {
        assertEq(address(pool).balance, ETHER_IN_POOL, "pool balance");
        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE, "player balance");
    }

    function test() public {
        vm.prank(player);
        Attack attack = new Attack(pool);

        attack.attack();
        attack.finalize();

        checkSuccess();
    }
}
