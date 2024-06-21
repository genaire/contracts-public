// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import "./IxGenaireBridge.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../IRestakeManager.sol";
import "../xERC20/interfaces/IXERC20Lockbox.sol";
import "../Connext/core/IConnext.sol";
import {
    IRouterClient
} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { IRateProvider } from "../../RateProvider/IRateProvider.sol";
import {
    LinkTokenInterface
} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import { IRoleManager } from "../../Permissions/IRoleManager.sol";

abstract contract xGenaireBridgeStorageV1 is IxGenaireBridge {
    /// @notice The xairETH token address
    IERC20 public xairETH;

    /// @notice The airETH token address
    IERC20 public airETH;

    /// @notice The RestakeManager contract - deposits into the protocol are restaked here
    IRestakeManager public restakeManager;

    /// @notice The wETH token address - will be sent via bridge from L2
    IERC20 public wETH;

    /// @notice The lockbox contract for airETH - minted airETH is sent here
    IXERC20Lockbox public xairETHLockbox;

    /// @notice The address of the main Connext contract
    IConnext public connext;

    /// @notice The address of the RateProvider Contract
    IRateProvider public rateProvider;

    /// @notice The address of the Chainlink CCIPv1.2.0 Router Client
    IRouterClient public linkRouterClient;

    /// @notice The address of Chainlink Token
    LinkTokenInterface public linkToken;

    /// @notice The address of Genaire RoleManager contract
    IRoleManager public roleManager;
}
