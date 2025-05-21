// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {PoolAddress} from "../lib/PoolAddress.sol";
import {Payments} from "./Payments.sol";

struct MintCallbackData {
    PoolAddress.PoolKey poolKey;
    address payer;
}

library MintCallback {
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        uint256 fee,
        bytes calldata data
    ) external override {
        MintCallbackData memory decoded = abi.decode(data, (MintCallbackData));

        PoolAddress.PoolKey memory poolKey = PoolAddress.PoolKey({
            token0: decoded.poolKey.token0,
            token1: decoded.poolKey.token1,
            fee: fee
        });

        pool = PoolAddress.computeAddress(factory, poolKey);

        require(msg.sender == pool, "Invalid sender");

        if (amount0Owed > 0)
            Payments.pay(
                decoded.poolKey.token0,
                decoded.payer,
                msg.sender,
                amount0Owed
            );
        if (amount1Owed > 0)
            Payments.pay(
                decoded.poolKey.token1,
                decoded.payer,
                msg.sender,
                amount1Owed
            );
    }
}
