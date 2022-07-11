// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.14;

import {Errors} from "./Errors.sol";

/**
  * @notice The configuration is shared for NFT reserve and normal reserve.
  * bit 0-15: LTV
  * bit 16-31: Liq. threshold
  * bit 32-39: Decimals
  * bit 40: Reserve is active
  * bit 41: reserve is frozen
  * bit 42: borrowing is enabled (always disabled for NFT reserves)
  * bit 43: reserved
  * bit 44-59: reserve factor
  * bit 60-61: token type: 0->ERC20 1->ERC721 2->ERC1155 (0 for normal reserves)
  * bit 62-63: reserved
  */
type ReserveConfiguration is uint256;

/**
 * @title ReserveConfigurator library
 * @author Taker
 * @notice Implements the bitmap logic to handle the reserve configuration
 */
contract ReserveConfigurator {
  string constant COMPONENT_NAME = "RC";

  uint256 constant LTV_MASK =                   0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000; //prettier-ignore
  uint256 constant LIQUIDATION_THRESHOLD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFF; //prettier-ignore
  uint256 constant DECIMALS_MASK =              0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFF; //prettier-ignore
  uint256 constant ACTIVE_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFEFFFFFFFFFF; //prettier-ignore
  uint256 constant FROZEN_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFF; //prettier-ignore
  uint256 constant BORROWING_MASK =             0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFFFFFFFFFF; //prettier-ignore
  uint256 constant RESERVE_FACTOR_MASK =        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFF; //prettier-ignore
  uint256 constant TOKEN_TYPE_MASK =            0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3FFFFFFFFFFFFFFF; //prettier-ignore

  // bit shiftings to get the start poistion for each variable 
  uint256 constant LIQUIDATION_THRESHOLD_SHIFT = 16;
  uint256 constant DECIMALS_SHIFT = 32;
  uint256 constant IS_ACTIVE_SHIFT = 40;
  uint256 constant IS_FROZEN_SHIFT = 41;
  //TODO: seems the borrowing bit is not useful
  uint256 constant BORROWING_ENABLED_SHIFT = 42;
  uint256 constant RESERVE_FACTOR_SHIFT = 60;
  uint256 constant TOKEN_TYPE_SHIFT = 62;

  uint256 constant MAX_LTV = 65535;
  uint256 constant MAX_LIQUIDATION_THRESHOLD = 65535;
  uint256 constant MAX_DECIMALS = 255;
  uint256 constant MAX_RESERVE_FACTOR = 65535;

  uint16 public constant MAX_NUMBER_RESERVES = 128;
  uint16 public constant MAX_NUMBER_NFT_RESERVES = 256;

  enum TokenType{ERC20, ERC721, ERC1155} 

  /**
   * @dev Returns configuration after setting new Loan to Value
   * @param configuration The reserve configuration
   * @param ltv The new ltv
   * @return The new configuration
   **/
  function setLtv(ReserveConfiguration configuration, uint256 ltv)
    public
    pure
    returns (ReserveConfiguration)
  {
    require(ltv <= MAX_LTV, Errors.genErrMsg(COMPONENT_NAME, Errors.INVALID_LTV));
    return
      ReserveConfiguration.wrap(
        (ReserveConfiguration.unwrap(configuration) & LTV_MASK) | ltv
      );
  }

  /**
    * @dev Gets the Loan to Value of the reserve
    * @param configuration The reserve configuration
    * @return The loan to value
    **/
  function getLtv(ReserveConfiguration configuration) public pure returns (uint256) {
    return ReserveConfiguration.unwrap(configuration) & ~LTV_MASK;
  }

  /**
    * @dev Returns configuration after setting new liquidation threshold
    * @param configuration The reserve configuration
    * @param threshold The new liquidation threshold
    * @return The new configuration
    **/
  function setLiquidationThreshold(ReserveConfiguration configuration, uint256 threshold)
    public
    pure
    returns (ReserveConfiguration)
  {
    require(threshold <= MAX_LIQUIDATION_THRESHOLD, Errors.genErrMsg(COMPONENT_NAME, Errors.INVALID_LIQ_THRESHOLD));
    return ReserveConfiguration.wrap((ReserveConfiguration.unwrap(configuration) & LIQUIDATION_THRESHOLD_MASK) | (threshold << LIQUIDATION_THRESHOLD_SHIFT));
  }

  /**
    * @dev Gets the liquidation threshold of the reserve
    * @param configuration The reserve configuration
    * @return The liquidation threshold
    **/
  function getLiquidationThreshold(ReserveConfiguration configuration)
    public
    pure
    returns (uint256)
  {
    return (ReserveConfiguration.unwrap(configuration) & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_SHIFT;
  }

  /**
    * @dev Returns configuration after setting new decimals
    * @param configuration The reserve configuration
    * @param decimals The new decimals
    * @return The new configuration
    **/
  function setDecimals(ReserveConfiguration configuration, uint256 decimals)
    public
    pure
    returns (ReserveConfiguration)
  {
    require(decimals <= MAX_DECIMALS, Errors.genErrMsg(COMPONENT_NAME, Errors.INVALID_DECIMALS));
 return ReserveConfiguration.wrap((ReserveConfiguration.unwrap(configuration) & DECIMALS_MASK) | (decimals << DECIMALS_SHIFT));
  }

  /**
    * @dev Gets the decimals of the underlying asset of the reserve
    * @param configuration The reserve configuration
    * @return The decimals of the asset
    **/
  function getDecimals(ReserveConfiguration configuration)
    public
    pure
    returns (uint256)
  {
    return (ReserveConfiguration.unwrap(configuration) & ~DECIMALS_MASK) >> DECIMALS_SHIFT;
  }

  /**
    * @dev Returns configuration after setting active state
    * @param configuration The reserve configuration
    * @param active The active state
        * @return The new configuration
    **/
  function setActive(ReserveConfiguration configuration, bool active) public pure returns (ReserveConfiguration){
  return
      ReserveConfiguration.wrap((ReserveConfiguration.unwrap(configuration) & ACTIVE_MASK) |
      (uint256(active ? 1 : 0) << IS_ACTIVE_SHIFT));
  }

  /**
    * @dev Gets the active state of the reserve
    * @param configuration The reserve configuration
    * @return The active state
    **/
  function getActive(ReserveConfiguration configuration) public pure returns (bool) {
    return (ReserveConfiguration.unwrap(configuration) & ~ACTIVE_MASK) != 0;
  }

  /**
    * @dev Returns configuration after setting frozen state
    * @param configuration The reserve configuration
    * @param frozen The frozen state
        * @return The new configuration
    **/
  function setFrozen(ReserveConfiguration configuration, bool frozen) public pure returns (ReserveConfiguration) {
  return 
      ReserveConfiguration.wrap((ReserveConfiguration.unwrap(configuration) & FROZEN_MASK) |
      (uint256(frozen ? 1 : 0) << IS_FROZEN_SHIFT));
  }

  /**
    * @dev Gets the frozen state of the reserve
    * @param configuration The reserve configuration
    * @return The frozen state
    **/
  function getFrozen(ReserveConfiguration configuration) public pure returns (bool) {
    return (ReserveConfiguration.unwrap(configuration) & ~FROZEN_MASK) != 0;
  }

  /**
    * @dev Returns new configuration after set borrowing state
    * @param configuration The reserve configuration
    * @param enabled True if enable borrowing, false otherwise
          * @return The new configuration
    **/
  function setBorrowingEnabled(ReserveConfiguration configuration, bool enabled)
    public
    pure
    returns (ReserveConfiguration)
  {
  return ReserveConfiguration.wrap((ReserveConfiguration.unwrap(configuration) & BORROWING_MASK) |
      (uint256(enabled ? 1 : 0) << BORROWING_ENABLED_SHIFT));
  }

  /**
    * @dev Gets the borrowing state of the reserve
    * @param configuration The reserve configuration
    * @return The borrowing state
    **/
  function getBorrowingEnabled(ReserveConfiguration configuration)
    public
    pure
    returns (bool)
  {
    return (ReserveConfiguration.unwrap(configuration) & ~BORROWING_MASK) != 0;
  }

  /**
    * @dev Returns new configuration after set reserve factor
    * @param configuration The reserve configuration
    * @param reserveFactor The reserve factor
       * @return The new configuration
    **/
  function setReserveFactor(ReserveConfiguration configuration, uint256 reserveFactor)
    public
    pure
    returns (ReserveConfiguration)
  {
    require(reserveFactor <= MAX_RESERVE_FACTOR, Errors.genErrMsg(COMPONENT_NAME, Errors.INVALID_RESERVE_FACTOR));

  return ReserveConfiguration.wrap(
      (ReserveConfiguration.unwrap(configuration) & RESERVE_FACTOR_MASK) |
      (reserveFactor << RESERVE_FACTOR_SHIFT));
  }

  /**
    * @dev Gets the reserve factor of the reserve
    * @param configuration The reserve configuration
    * @return The reserve factor
    **/
  function getReserveFactor(ReserveConfiguration configuration)
    public
    pure
    returns (uint256)
  {
    return (ReserveConfiguration.unwrap(configuration) & ~RESERVE_FACTOR_MASK) >> RESERVE_FACTOR_SHIFT;
  }

    /**
    * @dev Returns new configuration after set token type
    * @param configuration The reserve configuration
    * @param tokenType The type of the token
       * @return The new configuration
    **/
  function setTokenType(ReserveConfiguration configuration, TokenType tokenType)
    public
    pure
    returns (ReserveConfiguration)
  {
  return ReserveConfiguration.wrap(
      (ReserveConfiguration.unwrap(configuration) & TOKEN_TYPE_MASK) |
      (uint256(tokenType) << TOKEN_TYPE_SHIFT));
  }

  /**
    * @dev Gets the token type of the reserve
    * @param configuration The reserve configuration
    * @return The token type
    **/
  function getTokenType(ReserveConfiguration configuration)
    public
    pure
    returns (TokenType)
  {
    return TokenType((ReserveConfiguration.unwrap(configuration) & ~TOKEN_TYPE_MASK) >> TOKEN_TYPE_SHIFT);
  }

  /**
    * @dev Gets the configuration flags of the reserve
    * @param configuration The reserve configuration
    * @return The state flags of active, frozen and borrowing enabled
    **/
  function getFlags(ReserveConfiguration configuration)
    public
    pure
    returns (
      bool,
      bool,
      bool
    )
  {
    uint256 conf = ReserveConfiguration.unwrap(configuration);

    return (
      (conf & ~ACTIVE_MASK) != 0,
      (conf & ~FROZEN_MASK) != 0,
      (conf & ~BORROWING_MASK) != 0
    );
  }
}
