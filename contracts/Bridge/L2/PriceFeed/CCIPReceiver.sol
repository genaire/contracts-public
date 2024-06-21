// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {
    CCIPReceiver
} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";
import { IxGenaireDeposit } from "../IxGenaireDeposit.sol";
import "../../../Errors/Errors.sol";

/// @title CCIPReceiver - Base contract for CCIP applications that can receive messages.
contract Receiver is CCIPReceiver, Ownable, Pausable {
    /// @notice The Address of xGenaireBridge contract on L1
    address public xGenaireBridgeL1;

    /// @notice The chainlink source chain selector id for Ethereum
    uint64 public ccipEthChainSelector;

    /// @notice xGenaireDeposit Contract on L2
    IxGenaireDeposit public xGenaireDeposit;

    event XGenaireBridgeL1Updated(address newBridgeAddress, address oldBridgeAddress);
    event CCIPEthChainSelectorUpdated(uint64 newSourceChainSelector, uint64 oldSourceChainSelector);
    event XGenaireDepositUpdated(address newGenaireDeposit, address oldGenaireDeposit);
    /**
     *  @dev Event emitted when a message is received from another chain
     *  @param messageId  The unique ID of the message
     *  @param sourceChainSelector  The chain selector of the source chain
     *  @param sender  The address of the sender from the source chain.
     *  @param price  The price feed received on L2.
     *  @param timestamp  The timestamp when price feed was sent from L1.
     */
    event MessageReceived(
        bytes32 indexed messageId,
        uint64 indexed sourceChainSelector,
        address sender,
        uint256 price,
        uint256 timestamp
    );

    constructor(
        address _router,
        address _xGenaireBridgeL1,
        uint64 _ccipEthChainSelector
    ) CCIPReceiver(_router) {
        if (_xGenaireBridgeL1 == address(0) || _ccipEthChainSelector == 0) revert InvalidZeroInput();

        // Set xGenaireBridge L1 contract address
        xGenaireBridgeL1 = _xGenaireBridgeL1;

        // Set ccip source chain selector for Ethereum L1
        ccipEthChainSelector = _ccipEthChainSelector;

        // Pause The contract to setup xGenaireDeposit
        _pause();
    }

    /**
     * @notice  Updates the price feed
     * @dev     This function will receive the price feed from the L1.
     *          It should verify the origin of the call and only allow permissioned source to call.
     * @param   any2EvmMessage ccip Message received from L1 -> L2
     */
    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    ) internal override whenNotPaused {
        address _ccipSender = abi.decode(any2EvmMessage.sender, (address));
        uint64 _ccipSourceChainSelector = any2EvmMessage.sourceChainSelector;
        // Verify origin on the price feed
        if (_ccipSender != xGenaireBridgeL1) revert InvalidSender(xGenaireBridgeL1, _ccipSender);
        // Verify Source chain of the message
        if (_ccipSourceChainSelector != ccipEthChainSelector)
            revert InvalidSourceChain(ccipEthChainSelector, _ccipSourceChainSelector);
        (uint256 _price, uint256 _timestamp) = abi.decode(any2EvmMessage.data, (uint256, uint256));
        xGenaireDeposit.updatePrice(_price, _timestamp);
        emit MessageReceived(
            any2EvmMessage.messageId,
            _ccipSourceChainSelector,
            _ccipSender,
            _price,
            _timestamp
        );
    }

    /******************************
     *  Admin/OnlyOwner functions
     *****************************/

    /**
     * @notice This function updates the xGenaireBridge Contract address deployed on Ethereum L1
     * @dev This should be a permissioned call (onlyOnwer)
     * @param _newXGenaireBridgeL1 New address of xGenaireBridge Contract
     */
    function updateXGenaireBridgeL1(address _newXGenaireBridgeL1) external onlyOwner {
        if (_newXGenaireBridgeL1 == address(0)) revert InvalidZeroInput();
        emit XGenaireBridgeL1Updated(_newXGenaireBridgeL1, xGenaireBridgeL1);
        xGenaireBridgeL1 = _newXGenaireBridgeL1;
    }

    /**
     * @notice This function updates the allowed chainlink CCIP source chain selector
     * @dev This should be a permissioned call (onlyOnwer)
     * @param _newChainSelector New source chain selector
     */
    function updateCCIPEthChainSelector(uint64 _newChainSelector) external onlyOwner {
        if (_newChainSelector == 0) revert InvalidZeroInput();
        emit CCIPEthChainSelectorUpdated(_newChainSelector, ccipEthChainSelector);
        ccipEthChainSelector = _newChainSelector;
    }

    /**
     * @notice Pause the contract
     * @dev This should be a permissioned call (onlyOwner)
     */
    function unPause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice UnPause the contract
     * @dev This should be a permissioned call (onlyOwner)
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice This function updates the xGenaireDeposit Contract address
     * @dev This should be a permissioned call (onlyOnwer)
     * @param _newXGenaireDeposit New xGenaireDeposit Contract address
     */
    function setGenaireDeposit(address _newXGenaireDeposit) external onlyOwner {
        if (_newXGenaireDeposit == address(0)) revert InvalidZeroInput();
        emit XGenaireDepositUpdated(_newXGenaireDeposit, address(xGenaireDeposit));
        xGenaireDeposit = IxGenaireDeposit(_newXGenaireDeposit);
    }
}
