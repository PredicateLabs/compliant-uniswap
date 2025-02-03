# Compliant Bridge

This is a simple integration pattern for a compliant bridge. Specially it uses the Across protocol as an example but could be adapted to any other bridge or cross-chain messaging standard as long as there is asynchronous sending and recieving of messages between two domains.

## Dispatch

The `depositV3` function is used to send a message to the other domain. 

#### SpokePool.sol

```solidity
function depositV3(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityParameter,
        bytes calldata message
    ) public payable override nonReentrant unpausedDeposits {
        _depositV3(
            depositor,
            recipient,
            inputToken,
            outputToken,
            inputAmount,
            outputAmount,
            destinationChainId,
            exclusiveRelayer,
            numberOfDeposits++,
            quoteTimestamp,
            fillDeadline,
            exclusivityParameter,
            message
        );
    }
```