// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { BaseFixture } from "test/utils/Fixtures.sol";

contract TestSideEntrance is BaseFixture {
    function setUp() public {
        vm.startPrank(deployer);
        vm.stopPrank();
    }

    function checkSuccess() internal { }

    function test_setUp() public { }

    function test() public {
        vm.prank(player);
        checkSuccess();
    }
}
