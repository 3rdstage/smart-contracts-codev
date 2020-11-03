### Design Pricipal


* ***Extended Domain Model***
    * Inclusive and extended
    * `RewardPolicy`
    * `ProjectFactory`
    
* ***On-chain First***
    * Minimize off-chain usage
    
* ***More Fluent API using ABIEncoderV2***
    * Dyanmic array or struct in function parameters and outputs

* ***Follow EIP Standars***
    
* ***Secure Contract***
    * Code inspection using `MythX`(ConsenSys), `Slither`, and `Solhint`
    * Thorough uint testing

    

### Implementation Principle

* ***Resue Best Practices***
    * [`OpenZeppelin Contract`](https://github.com/OpenZeppelin/openzeppelin-contracts) library
        * v3.2.0 for Solidity 0.6.x compatibility

        | Library | Description |
        | ------- | ----------- |
        | [`Context`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/GSN/Context.sol) |            |
        | [`AccessControl`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/access/AccessControl.sol) |   |
        | [`SafeMath`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol) | overflow free arithmetics |
        | [`EnumerableSet.AddressSet`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol) |   |
        | [`EnumerableMap.UintToAddressMap`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableMap.sol) |   |
        
        
        
        
        
        
        
             

    