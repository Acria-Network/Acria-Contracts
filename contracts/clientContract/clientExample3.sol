// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;


interface AcriaNode {
    function create_request_with_data(bytes8 _requestID, address callback, uint256 _expire, uint32 max_gas, uint256 _data, uint256 _data_passthrough) external payable;
}

contract ClientExample3 {
    //The address of the targeted Oracle Node
    address payable node;

    //last most recent value received via a callback
    mapping(uint256 => uint256) public lastValue;
    
    uint256 counter;

    constructor(address payable _node) {
        node = _node;
    }

    function callOracle() public payable{
        //make a call to the Oracle Node and include the fee (all ETH provided)
        //1. parameter is the item requested in this case the USD/GBP exchange rate
        //2. parameter is the callback address (this contract)
        //3. parameter is the request expire date. It is expressed in blocks until the request should be dropped.
        //4. parameter is the amount of gas the oracle node should provide for the callback. The higher the requested gas the higher should be the fee provided.
        //5. parameter is the request data which further specifies the data needed (here: the current timestamp)
        //6. parameter is the passthrough data which will be passed through to the callback function (see third parameter of the callback)
        AcriaNode(node).create_request_with_data{value: msg.value, gas: 100000}("USD/GBP", address(this), 10000, 50000, block.timestamp, counter);
        
        counter++;
    }
    
    //the function which gets called by the Oracle Node
    //it must be named value_callback with exactly three uint256 as parameter
    function value_callback(uint256 _value, uint256 data, uint256 data_passthrough) public{
        //only the Oracle Node is allowed to call this function
        require(msg.sender == node);

        //update the value
        lastValue[data_passthrough] = _value;
    }
}
