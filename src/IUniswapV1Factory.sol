// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV1Factory {
    function initializeFactory(address template) external;

    function createExchange(address token) external returns (address);
}
