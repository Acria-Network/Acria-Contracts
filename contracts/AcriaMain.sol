pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;


import "./AcriaNode.sol";

contract AcriaMain {

  struct node{
  	address location;
  	bytes32 owner;
  }
  
  
  address public owner = msg.sender;
  
  node[] nodes;
  mapping(address => bool) node_active;
  mapping(bytes32 => bool) name_exists;


  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }


  function createNode(bytes32 _owner) public {
    require(name_exists[_owner] == false);
    
    AcriaNode acria_node = new AcriaNode(msg.sender);
    
    node memory new_node = node({location: address(acria_node), owner: _owner});
    nodes.push(new_node);
    
    node_active[address(acria_node)] = true;
    name_exists[_owner] = true;
  }
  
  
  function getField(address _node, bytes32 requestID, uint256 expire, address _callback) public {
    require(expire > 10);
    
    AcriaNode acria_node = AcriaNode(_node);
    
    acria_node.create_request(requestID, _callback, expire);
  }
  
  
  function is_node(address _node) public view returns(bool) {
    return node_active[_node];
    
  }
  
  function get_nodes() public view returns(node[] memory) {
    return nodes;
    
  }
  
}
