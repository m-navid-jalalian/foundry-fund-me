// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
//  HelperConfig is use for mock:
// 1. It deploys mocks when we're on a local anvil chain
// 2. Maintains track of contract addresses across various chains

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //If we are  on a local anvil chain, we deploy moocks
    //otherwise, grap the existing address from the live network

    struct NetworkConfig {
        address priceFeed; //ETH/USD priceFeed address
    }

    NetworkConfig public activeNetowrkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetowrkConfig = getSepoliaEthConfig();
        } else {
            activeNetowrkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }
    // for adding anothers chains we can add exact ablove function with different perice feed adderess

    //for anvil, its different
    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetowrkConfig.priceFeed != address(0)) {
            //for dont set the priceFeed, if it did before
            return activeNetowrkConfig;
        }

        // 1.Deploy the mocks
        // 2.Return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}
