// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;


interface AcriaNode {
    function create_request_with_data(bytes8 _requestID, address callback, uint256 _expire, uint32 max_gas, uint256 _data, uint256 _data_passthrough) external payable;
    function create_request(bytes8 _requestID, address callback, uint256 _expire, uint32 max_gas) external payable;
}

contract ClientExample4 {
    //The address of the targeted Oracle Node
    address payable node;
    address master;

    //last most recent value received via a callback
    mapping(uint256 => uint256) public lastValue;
    
    //last most recent value received via a callback
    uint256 public _lastValue;
    
    uint256 public counter;

    constructor(address payable _node) {
        node = _node;
        master = msg.sender;
    }
    
    function set_oracle(address payable _node) public{
    	require(msg.sender == master);
    	
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
    
    function callOracle(bytes8 field, uint256 parameter) public payable{
        AcriaNode(node).create_request_with_data{value: msg.value, gas: 100000}(field, address(this), 10000, 50000, parameter, counter);
        
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
    
    function callOracleSimple() public payable{
        //make a call to the Oracle Node and include the fee (all ETH provided)
        //first parameter is the item requested in this case the USD/GBP exchange rate
        //the second parameter is the callback address (this contract)
        //the third is the request expire date. It is expressed in blocks until the request should be dropped.
        //the fourth is the amount of gas the oracle node should provide for the callback. The higher the requested gas the higher should be the fee provided.
        AcriaNode(node).create_request{value: msg.value, gas: 100000}("USD/GBP", address(this), 10000, 50000);
    }
    
    function callOracleSimple(bytes8 field) public payable{
        AcriaNode(node).create_request{value: msg.value, gas: 100000}(field, address(this), 10000, 50000);
    }

    //the function which gets called by the Oracle Node
    //it must be named value_callback with exactly one uint256 as parameter
    function value_callback(uint256 _value) public{
        //only the Oracle Node is allowed to call this function
        require(msg.sender == node);

        //update the value
        _lastValue = _value;
    }
}
