// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./IAirEthToken.sol";
import "../Permissions/IRoleManager.sol";
import "./AirEthTokenStorage.sol";
import "../Errors/Errors.sol";

/// @dev This contract is the AirETH ERC20 token
/// Ownership of the collateral in the protocol is tracked by the AirETH token
contract AirEthToken is Initializable, ERC20Upgradeable, IAirEthToken, AirEthTokenStorageV1 {
    /// @dev Allows only a whitelisted address to mint or burn AirETH tokens
    modifier onlyMinterBurner() {
        if (!roleManager.isAirETHMinterBurner(msg.sender)) revert NotAirETHMinterBurner();
        _;
    }

    /// @dev Allows only a whitelisted address to pause or unpause the token
    modifier onlyTokenAdmin() {
        if (!roleManager.isTokenAdmin(msg.sender)) revert NotTokenAdmin();
        _;
    }

    /// @dev Prevents implementation contract from being initialized.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @dev Initializes the contract with initial vars
    function initialize(IRoleManager _roleManager) public initializer {
        if (address(_roleManager) == address(0x0)) revert InvalidZeroInput();

        __ERC20_init("AirETH", "Renzo Restaked ETH");
        roleManager = _roleManager;
    }

    /// @dev Allows minter/burner to mint new AirETH tokens to an address
    function mint(address to, uint256 amount) external onlyMinterBurner {
        _mint(to, amount);
    }

    /// @dev Allows minter/burner to burn AirETH tokens from an address
    function burn(address from, uint256 amount) external onlyMinterBurner {
        _burn(from, amount);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return "Renzo Restaked ETH";
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return "AirETH";
    }
}
