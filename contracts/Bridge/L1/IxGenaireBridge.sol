// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

interface IxGenaireBridge {
    /**
     * @notice Contains destination data for CCIP call
     *
     * @param destinationChainSelector chainlink CCIP destination chain selector ID
     * @param _genaireReceiver xgenaireDeposit receiver contract
     */
    struct CCIPDestinationParam {
        uint64 destinationChainSelector;
        address _genaireReceiver;
    }

    /**
     * @notice Contains destination data for Connext xCall
     *
     * @param destinationChainSelector chainlink Connext destination chain domain ID
     * @param _genaireReceiver xGenaireDeposit receiver contract
     * @param relayerFee relayer Fee required for xCall
     */
    struct ConnextDestinationParam {
        uint32 destinationDomainId;
        address _genaireReceiver;
        uint256 relayerFee;
    }

    function sendPrice(
        CCIPDestinationParam[] calldata _destinationParam,
        ConnextDestinationParam[] calldata _connextDestinationParam
    ) external payable;
}
