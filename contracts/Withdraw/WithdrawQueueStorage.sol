// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import "../Permissions/IRoleManager.sol";
import "../Oracle/IGenaireOracle.sol";
import "../IRestakeManager.sol";
import "../token/IAirEthToken.sol";

abstract contract WithdrawQueueStorageV1 {
    address public constant IS_NATIVE = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    struct TokenWithdrawBuffer {
        address asset;
        uint256 bufferAmount;
    }

    struct WithdrawRequest {
        address collateralToken;
        uint256 withdrawRequestID;
        uint256 amountToRedeem;
        uint256 airETHLocked;
        uint256 createdAt;
    }

    /// @dev reference to the GenaireOracle contract
    IGenaireOracle public genaireOracle;

    /// @dev reference to the airETH token contract
    IAirEthToken public airETH;

    /// @dev reference to the RoleManager contract
    IRoleManager public roleManager;

    /// @dev reference to the RestakeManager contract
    IRestakeManager public restakeManager;

    /// @dev cooldown period for user to claim their withdrawal
    uint256 public coolDownPeriod;

    /// @dev nonce for tracking withdraw requests, This only increments (doesn't decrement)
    uint256 public withdrawRequestNonce;

    /// @dev mapping of withdrawalBufferTarget, indexed by token address
    mapping(address => uint256) public withdrawalBufferTarget;

    /// @dev mapping of claimReserve (already withdraw requested), indexed by token address
    mapping(address => uint256) public claimReserve;

    /// @dev mapiing of withdraw requests array, indexed by user address
    mapping(address => WithdrawRequest[]) public withdrawRequests;
}
