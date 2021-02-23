pragma solidity >=0.4.22 <0.9.0;

import "../clientContract/client.sol";

contract ExampleClient is Client {
  uint256 lastValue;
  
  function value_callback_process(uint256 _value) public {
     lastValue = _value;
  }
  
  function get_lastValue() public view returns(uint256) {
    return lastValue;
    
  }
  
}
