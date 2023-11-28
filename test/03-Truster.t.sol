// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { BaseFixture } from "test/utils/Fixtures.sol";

import { DamnValuableToken } from "src/DamnValuableToken.sol";
import { TrusterLenderPool } from "src/03-Truster/TrusterLenderPool.sol";

contract TestTruster is BaseFixture {
    uint256 public constant TOKENS_IN_POOL = 1_000_000 ether;

    DamnValuableToken token;
    TrusterLenderPool pool;

    function setUp() public {
        vm.startPrank(deployer);
        token = new DamnValuableToken();
        pool = new TrusterLenderPool(token);

        token.transfer(address(pool), TOKENS_IN_POOL);

        vm.stopPrank();
    }

    function checkSuccess() internal {
        assertEq(token.balanceOf(player), TOKENS_IN_POOL);
        assertEq(token.balanceOf(address(pool)), 0);
    }

    function test_setUp() public {
        assertEq(address(pool.token()), address(token));
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(player), 0);
    }

    function test() public {
        checkSuccess();
    }
}
