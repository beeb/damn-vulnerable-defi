// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { BaseFixture } from "test/utils/Fixtures.sol";

import { DamnValuableToken } from "src/DamnValuableToken.sol";
import { PuppetPool } from "src/08-Puppet/PuppetPool.sol";
import { IUniswapV1Exchange } from "src/IUniswapV1Exchange.sol";
import { IUniswapV1Factory } from "src/IUniswapV1Factory.sol";

contract TestPuppet is BaseFixture {
    uint256 public constant UNISWAP_INITIAL_TOKEN_RESERVE = 10 ether;
    uint256 public constant UNISWAP_INITIAL_ETH_RESERVE = 10 ether;
    uint256 public constant PLAYER_INITIAL_TOKEN_BALANCE = 1000 ether;
    uint256 public constant PLAYER_INITIAL_ETH_BALANCE = 25 ether;
    uint256 public constant POOL_INITIAL_TOKEN_BALANCE = 100_000 ether;

    DamnValuableToken internal token;
    IUniswapV1Factory internal uniswapFactory;
    IUniswapV1Exchange internal uniswapExchange;
    PuppetPool internal lendingPool;

    function setUp() public {
        deal(player, PLAYER_INITIAL_ETH_BALANCE);
        vm.startPrank(deployer);
        token = new DamnValuableToken();
        uniswapFactory = IUniswapV1Factory(deployCode("src/build-uniswap/UniswapV1Factory.json"));
        IUniswapV1Exchange uniswapExchangeTemplate =
            IUniswapV1Exchange(deployCode("src/build-uniswap/UniswapV1Exchange.json"));
        uniswapFactory.initializeFactory(address(uniswapExchangeTemplate));
        uniswapExchange = IUniswapV1Exchange(uniswapFactory.createExchange(address(token)));
        lendingPool = new PuppetPool(address(token), address(uniswapExchange));
        token.approve(address(uniswapExchange), UNISWAP_INITIAL_TOKEN_RESERVE);
        uniswapExchange.addLiquidity{ value: UNISWAP_INITIAL_ETH_RESERVE }(
            0, UNISWAP_INITIAL_TOKEN_RESERVE, block.timestamp + 10
        );
        token.transfer(address(player), PLAYER_INITIAL_TOKEN_BALANCE);
        token.transfer(address(lendingPool), POOL_INITIAL_TOKEN_BALANCE);
        vm.stopPrank();
    }

    function test_setUp() public view {
        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE);
        assertEq(
            uniswapExchange.getTokenToEthInputPrice(1 ether),
            calculateTokenToEthInputPrice(1 ether, UNISWAP_INITIAL_TOKEN_RESERVE, UNISWAP_INITIAL_ETH_RESERVE)
        );
    }

    function calculateTokenToEthInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve)
        internal
        pure
        returns (uint256)
    {
        uint256 input_amount_with_fee = input_amount * 997;
        uint256 numerator = input_amount_with_fee * output_reserve;
        uint256 denominator = (input_reserve * 1000) + input_amount_with_fee;
        return numerator / denominator;
    }

    function test() public {
        assertEq(vm.getNonce(player), 1, "nonce");
        assertEq(token.balanceOf(address(lendingPool)), 0, "pool balance");
        assertGe(token.balanceOf(player), POOL_INITIAL_TOKEN_BALANCE, "pool balance");
    }
}
