// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";

import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {CurrencySettler} from "@uniswap/v4-core/test/utils/CurrencySettler.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/src/types/BeforeSwapDelta.sol";
import {SafeCast} from "@uniswap/v4-core/src/libraries/SafeCast.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";

import {PredicateClient} from "lib/predicate-std/src/mixins/PredicateClient.sol";
import {PredicateMessage} from "lib/predicate-std/src/interfaces/IPredicateClient.sol";
import {IPredicateManager} from "lib/predicate-std/src/interfaces/IPredicateManager.sol";

contract CompliantDex is BaseHook, PredicateClient {
    using CurrencyLibrary for Currency;
    using CurrencySettler for Currency;
    using PoolIdLibrary for PoolKey;
    using SafeCast for uint256;
    using SafeCast for uint128;
    using StateLibrary for IPoolManager;

    error PoolNotInitialized();
    error TickSpacingNotDefault();
    error LiquidityDoesntMeetMinimum();
    error SenderMustBeHook();
    error ExpiredPastDeadline();
    error TooMuchSlippage();
    error SwapsNotAllowed();

    event SwapAttemptBlocked(address sender, PoolKey key);
    event LiquidityAdded(address sender, uint256 amount0, uint256 amount1);

    bytes internal constant ZERO_BYTES = bytes("");

    int24 internal constant MIN_TICK = -887220;
    int24 internal constant MAX_TICK = -MIN_TICK;

    int256 internal constant MAX_INT = type(int256).max;
    uint16 internal constant MINIMUM_LIQUIDITY = 1000;

    mapping(PoolId => uint256) public poolInfo;
    mapping(PoolId => uint256) public beforeRemoveLiquidityCount;
    mapping(PoolId => uint256) public afterSwapCount;
    mapping(address => bool) public allowedLiquidityProviders;
    mapping(address => bool) public whitelist;

    CompliantDex public fullRange;

    constructor(IPoolManager _poolManager, address _ServiceManager, string memory _policyID, CompliantDex _fullRange) 
        BaseHook(_poolManager) 
    {
        fullRange = _fullRange;
        _initPredicateClient(_ServiceManager, _policyID);
    }

    function isWhitelisted(address sender) public view returns (bool) {
        return whitelist[sender];
    }

    function updateWhitelist(address sender, bool status) external {
        whitelist[sender] = status;
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: true,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: true,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function beforeSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata data) 
        external override returns (bytes4, BeforeSwapDelta, uint24) 
    {
        if (isWhitelisted(sender)) {
            return fullRange.beforeSwap(sender, key, params, data);
        }
        revert SwapsNotAllowed();
    }

    function beforeAddLiquidity(address sender, PoolKey calldata key, IPoolManager.ModifyLiquidityParams calldata params, bytes calldata data)
        external override returns (bytes4)
    {
        require(isWhitelisted(sender), "Sender not compliant");
        return fullRange.beforeAddLiquidity(sender, key, params, data);
    }

    function beforeRemoveLiquidity(address, PoolKey calldata key, IPoolManager.ModifyLiquidityParams calldata, bytes calldata)
        external override returns (bytes4) 
    {
        beforeRemoveLiquidityCount[key.toId()]++;
        return BaseHook.beforeRemoveLiquidity.selector;
    }
}
