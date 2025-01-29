# Compliant Uniswap V4

Compliant, decentralized exchange powered by [Predicate](https://docs.predicate.io).

## Usage

```
forge build
```

## Compliance Check

```
constructor(IPoolManager _poolManager, address _ServiceManager, string memory _policyID, BaseHook _amm) 
        BaseHook(_poolManager) 
    {
        amm = _amm;
        _initPredicateClient(_ServiceManager, _policyID);
        owner = msg.sender;
    }

    function isWhitelisted(address sender) public view returns (bool) {
        return whitelist[sender];
    }

    function updateWhitelist(address sender, bool status) external {
        whitelist[sender] = status;
    }   
```

---

Additional resources:

[Uniswap v4 docs](https://docs.uniswap.org/contracts/v4/overview)

[Predicate docs](https://docs.predicate.io)

