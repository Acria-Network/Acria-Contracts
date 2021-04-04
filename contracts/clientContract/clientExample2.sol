// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;


interface AcriaNode {
    function create_request(bytes8 _requestID, address callback, uint256 _expire, uint32 max_gas) external payable;
}

contract ClientExample2 {
    //The address of the targeted Oracle Node
    address payable node;

    //last most recent value received via a callback
    uint256 public lastValue;

    constructor(address payable _node) {
        node = _node;
    }

    function callOracle() public payable{
        //make a call to the Oracle Node and include the fee (all ETH provided)
        //first parameter is the item requested in this case the USD/GBP exchange rate
        //the second parameter is the callback address (this contract)
        //the third is the request expire date. It is expressed in blocks until the request should be dropped.
        //the fourth is the amount of gas the oracle node should provide for the callback. The higher the requested gas the higher should be the fee provided.
        AcriaNode(node).create_request{value: msg.value, gas: 100000}("USD/GBP", address(this), 10000, 50000);
    }

    //the function which gets called by the Oracle Node
    //it must be named value_callback with exactly one uint256 as parameter
    function value_callback(uint256 _value) public{
        //only the Oracle Node is allowed to call this function
        require(msg.sender == node);

        //update the value
        lastValue = _value;
    }
}