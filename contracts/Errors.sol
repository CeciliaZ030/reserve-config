// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.14;

/**
 * @title Errors library
 * @author Taker
 * @notice Error message mapping for Taker protocol
 */
library Errors {
  //TODO: sort out the error numbers
  //common errors
  string public constant ONLY_POOL_ADMIN = "0";
  string public constant ONLY_LENDING_POOL = "1";
  string public constant ONLY_LENDING_POOL_CONFIGURATOR = "2";

  // token errors
  string public constant INVALID_MINT_AMOUNT = "1";
  string public constant INVALID_BURN_AMOUNT = "2";
  string public constant TOKEN_NOT_TRANSFERRABLE = "4";

  // configuration errors
  string public constant INVALID_LTV = "1";
  string public constant INVALID_LIQ_THRESHOLD = "2";
  string public constant INVALID_DECIMALS = "3";
  string public constant INVALID_RESERVE_FACTOR = "4";

  string public constant INVALID_AMOUNT = "5";
  string public constant INACTIVE_RESERVE = "6";
  string public constant FROZEN_RESERVE = "7";
  string public constant RESERVE_ALREADY_INITIALIZED = "8";

  string public constant ARRAY_LENGTH_NOT_MATCH = "9";
  string public constant ERC_1155_OR_721_MUST_HAVE_TOKEN_ID = "10";
  string public constant USER_BALANCE_NOT_ENOUGH = "11";
  string public constant INVALID_INDEX = "12";
  string public constant HEALTH_FACTOR_UNDER_THRESHOLD = "13";
  string public constant BORROWING_NOT_ENABLED = "14";
  string public constant COLLATERAL_NOT_ENOUGH_FOR_BORROW = "15";
  string public constant ZERO_COLLATERAL_BALANCE = "16";
  string public constant NO_DEBT_TO_REPAY = "17";
  string public constant NOT_A_CONTRACT = "18";
  string public constant NO_MORE_RESERVES_ALLOWED = "19";
  string public constant NO_MORE_NFT_RESERVES_ALLOWED = "20";
  string public constant ZERO_BALANCE = "21";
  string public constant LIQ_THRESHOLD_LESS_THAN_LTV = "22";
  string public constant RESERVE_LIQUIDITY_NOT_ZERO = "23";

  /**
   * @dev Helper function to generate error messages
   * @param component The name of the component that produces the error
   * @param errCode The error code define in this library
   * @return The final error message
   **/
  function genErrMsg(string memory component, string memory errCode)
    external
    pure
    returns (string memory)
  {
    return string.concat(component, "_", errCode);
  }
}
