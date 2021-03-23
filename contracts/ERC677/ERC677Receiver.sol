// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

abstract contract ERC677Receiver {
  function onTokenTransfer(address _sender, uint _value, bytes memory _data) public virtual;
}
