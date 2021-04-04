// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

import "../AcriaMain.sol";

abstract contract Client {
  address acria_contract;
  
  function value_callback_process(uint256 _value) virtual public;
  
  function value_callback(uint256 _value) public {  
     AcriaMain acria_main = AcriaMain(acria_contract); 
      
      address sender = address(msg.sender);
     if(acria_main.is_node(sender)){
     	uint256 value = _value;
     	
     	this.value_callback_process(value);
     }
  }
}
