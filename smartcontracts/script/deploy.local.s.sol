// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {AztecaNFT} from "../src/AztecaNFT.sol";

contract Local is Script {
    AztecaNFT aztecaNFT;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

        aztecaNFT = new AztecaNFT();
        console2.log("Counter address: ", address(aztecaNFT));

        vm.stopBroadcast();
    }
}
