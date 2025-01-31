// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";

import {CompliantUniswap} from "./CompliantUniswap.sol";

import { PredicateClient } from "predicate-std/src/mixins/PredicateClient.sol";
import { PredicateMessage } from "predicate-std/src/interfaces/IPredicateClient.sol";


contract PredicateWrapper is PredicateClient, IHooks {
    constructor(address _serviceManager, string memory _policyID) {
        _initPredicateClient(_serviceManager, _policyID);
    }

    function beforeSwap(
        address sender, 
        PoolKey calldata key, 
        IPoolManager.SwapParams calldata params, 
        bytes calldata data
    ) external override returns (bytes4 hookAction, bytes memory hookData) {
        (
            PredicateMessage memory predicateMessage,
            address msgSender,
            uint256 amount0,
            uint256 amount1
        ) = abi.decode(data, (PredicateMessage, address, uint256, uint256));

        bytes memory encodeSigAndArgs = abi.encodeWithSignature(
            "_beforeSwap(address,PoolKey,IPoolManager.SwapParams,bytes)",
            sender,
            key,
            params,
            data
        );

    require(
            _authorizeTransaction(
                predicateMessage, 
                encodeSigAndArgs, 
                msgSender,         
                amount0,           
                amount1            
            ),
            "Unauthorized transaction"
        );

        return (Hooks.BEFORE_SWAP, data);
    }

    function setPolicy(string memory _policyID) external {
        _setPolicyID(_policyID);
    }

    function setPredicateManager(address _predicateManager) public {
        _setPredicateManager(_predicateManager);
    }
}