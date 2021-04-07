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
