// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";

import {CompliantDex} from "./CompliantDex.sol";

contract PredicateWrapper is IHooks {
    FullRange public immutable fullRangeHook;

    error SwapsNotAllowed();

    constructor(FullRange _fullRangeHook) {
        fullRangeHook = _fullRangeHook;
    }

    function beforeInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96)
        external
        override
        returns (bytes4)
    {
        return fullRangeHook.beforeInitialize(sender, key, sqrtPriceX96, msg.data);
    }

    function afterInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96, int24 tick)
        external
        override
        returns (bytes4)
    {
        return Hooks.AFTER_INITIALIZE;
    }

    function beforeAddLiquidity(address sender, PoolKey calldata key, IPoolManager.ModifyLiquidityParams calldata params, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        return fullRangeHook.beforeAddLiquidity(sender, key, params, data);
    }

    function afterAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta0,
        BalanceDelta delta1,
        bytes calldata data
    ) external override returns (bytes4, BalanceDelta) {
        return fullRangeHook.afterAddLiquidity(sender, key, params, delta0, delta1, data);
    }

    function beforeRemoveLiquidity(address sender, PoolKey calldata key, IPoolManager.ModifyLiquidityParams calldata params, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        return fullRangeHook.beforeRemoveLiquidity(sender, key, params, data);
    }

    function afterRemoveLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta0,
        BalanceDelta delta1,
        bytes calldata data
    ) external override returns (bytes4, BalanceDelta) {
        return fullRangeHook.afterRemoveLiquidity(sender, key, params, delta0, delta1, data);
    }

    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata data
    ) external override returns (bytes4, BeforeSwapDelta, uint24) {
        revert SwapsNotAllowed();
    }

    function afterSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata data
    ) external override returns (bytes4, int128) {
        return Hooks.AFTER_SWAP;
    }

    function beforeDonate(
        address sender,
        PoolKey calldata key,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external override returns (bytes4) {
        return fullRangeHook.beforeDonate(sender, key, amount0, amount1, data);
    }

    function afterDonate(
        address sender,
        PoolKey calldata key,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external override returns (bytes4) {
        return fullRangeHook.afterDonate(sender, key, amount0, amount1, data);
    }
}
