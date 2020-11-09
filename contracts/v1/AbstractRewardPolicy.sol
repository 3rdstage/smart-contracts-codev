pragma solidity >0.6.6 <0.7.0;
pragma experimental ABIEncoderV2;
import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "./IRewardPolicy.sol";
abstract contract AbstractRewardPolicy is IRewardPolicy, Context, AccessControl {
}