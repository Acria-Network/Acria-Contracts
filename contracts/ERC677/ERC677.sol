// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

import "./ERC20/IERC20.sol";

abstract contract ERC677 is IERC20 {
  function transferAndCall(address to, uint value, bytes memory data) public virtual returns (bool success);

  event Transfer(address indexed from, address indexed to, uint value, bytes data);
}
