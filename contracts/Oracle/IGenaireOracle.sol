// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IGenaireOracle {
    function lookupTokenValue(IERC20 _token, uint256 _balance) external view returns (uint256);
    function lookupTokenAmountFromValue(
        IERC20 _token,
        uint256 _value
    ) external view returns (uint256);
    function lookupTokenValues(
        IERC20[] memory _tokens,
        uint256[] memory _balances
    ) external view returns (uint256);
    function calculateMintAmount(
        uint256 _currentValueInProtocol,
        uint256 _newValueAdded,
        uint256 _existingAirETHSupply
    ) external pure returns (uint256);
    function calculateRedeemAmount(
        uint256 _airETHBeingBurned,
        uint256 _existingAirETHSupply,
        uint256 _currentValueInProtocol
    ) external pure returns (uint256);
}
