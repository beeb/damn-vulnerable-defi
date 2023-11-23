// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { Test } from "forge-std/Test.sol";

contract BaseFixture is Test {
    uint256 public deployerKey;
    address public deployer;

    uint256 public playerKey;
    address public player;

    uint256 public someUserKey;
    address public someUser;

    constructor() {
        (deployer, deployerKey) = makeAddrAndKey("deployer");
        (player, playerKey) = makeAddrAndKey("player");
        (someUser, someUserKey) = makeAddrAndKey("someUser");
        deal(deployer, 1_000_000 ether);
        deal(player, 1_000_000 ether);
        deal(someUser, 1_000_000 ether);
    }

    function sendEther(address to, uint256 amount) public {
        (bool success,) = to.call{ value: amount }("");
        require(success, "failed to send ether");
    }
}
