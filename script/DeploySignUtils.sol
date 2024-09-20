// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/SignUtils.sol";

contract DeploySignUtils is Script {
    function deploySignUtils() public returns (SignUtils) {
        vm.startBroadcast();
        SignUtils signUtils = new SignUtils();
        vm.stopBroadcast();

        return signUtils;
    }

    function run() public returns (SignUtils) {
        return deploySignUtils();
    }
}
