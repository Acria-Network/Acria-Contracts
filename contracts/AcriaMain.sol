// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;


import "./AcriaNode.sol";
import "./clientContract/client.sol";

contract AcriaMain {
  address public token_contract;

  struct node{
  	address location;
  	bytes32 owner;
  }
  
  
  address public owner = msg.sender;
  
  node[] nodes;
  mapping(address => bool) node_active;
  mapping(bytes32 => address) name_exists;


  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }


  constructor(address payable _token_contract) {
  	token_contract = _token_contract;
  }
  
  function createNode(bytes32 _owner) public {
    require(name_exists[_owner] == address(0));
    
    AcriaNode acria_node = new AcriaNode(payable(msg.sender), token_contract);
    
    node memory new_node = node({location: address(acria_node), owner: _owner});
    nodes.push(new_node);
    
    node_active[address(acria_node)] = true;
    name_exists[_owner] = address(acria_node);
  }
  
  /*
  function getField(address _node, bytes8 requestID, uint64 expire, address _callback, uint32 max_gas) public payable {
    require(expire > 100);
    require(msg.value < 10**18);
    require(expire < 1000000);
    require(max_gas < 500000);
    
    AcriaNode acria_node = AcriaNode(_node);
    acria_node.create_request{value:msg.value}(requestID, _callback/*Client(_callback).value_callback*/  //, expire, max_gas);
  //}
  
  
  function is_node(address _node) public view returns(bool) {
    return node_active[_node];
    
  }
  
  function get_contract(bytes32 name) public view returns(address) {
    return name_exists[name];
    
  }
  
  function get_nodes() public view returns(node[] memory) {
    return nodes;
    
  }
  
}
