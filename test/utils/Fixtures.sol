// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";

contract BaseFixture is Test {
    uint256 public deployerKey;
    address public deployer;

    uint256 public playerKey;
    address public player;

    uint256 public aliceKey;
    address public alice;
    uint256 public bobKey;
    address public bob;
    uint256 public charlieKey;
    address public charlie;
    uint256 public davidKey;
    address public david;

    constructor() {
        (deployer, deployerKey) = makeAddrAndKey("deployer");
        (player, playerKey) = makeAddrAndKey("player");
        (alice, aliceKey) = makeAddrAndKey("alice");
        (bob, bobKey) = makeAddrAndKey("bob");
        (charlie, charlieKey) = makeAddrAndKey("charlie");
        (david, davidKey) = makeAddrAndKey("david");
        deal(deployer, 1_000_000 ether);
        deal(player, 1_000_000 ether);
        deal(alice, 1_000_000 ether);
        deal(bob, 1_000_000 ether);
        deal(charlie, 1_000_000 ether);
        deal(david, 1_000_000 ether);
    }

    function sendEther(address to, uint256 amount) public {
        (bool success,) = to.call{ value: amount }("");
        require(success, "failed to send ether");
    }
}
