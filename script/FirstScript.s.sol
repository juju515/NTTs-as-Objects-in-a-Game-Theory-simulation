// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

// import {Identity_NTT_Factory} from "src/1_IdentityNTT.sol";
import {CentipedeGame} from "src/2_CentipedeGame.sol";

contract FirstScript is Script, Test {
    // function setUp() public {}


    address alice = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);


    function run() public {
        vm.startBroadcast(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d);
        CentipedeGame centipedegame = new CentipedeGame();


        vm.stopBroadcast();

        vm.startPrank(alice);
        centipedegame.mintIdNTT();
        uint x = centipedegame.balanceOf(alice);
        console.logUint(x);
        emit log_named_uint("This is the balance Of: ", x);
        vm.stopPrank();
    }
}
