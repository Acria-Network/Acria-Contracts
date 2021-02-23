pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./clientContract/client.sol";

contract AcriaNode {

  struct item {
	uint256 value;
	bool available;
  }
  
  
  struct request {
	bytes32 requestID;
	bool cancelled;
	uint256 expiration;
	address callback;
  }
  
  event RequestFilled(bytes32 requestID, address callback, uint256 value);
  
  address public owner;
  address master;
  mapping(bytes32 => bool) items;
  bytes32[] a_items;
  request[] requests;
  uint256 completedRequests = 0;
  uint256 fee = 0;
  
  constructor(address _owner) public {
  	owner = _owner;
  	master = msg.sender;
  }


  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }


  function create_request(bytes32 _requestID, address callback, uint256 _expire) public {
    require(msg.sender == master);
    
    uint256 blockNumber = block.number;
    uint256 expire = blockNumber + _expire;
    
    request memory new_request = request({requestID: _requestID, cancelled: false, expiration: expire, callback: callback});
    requests.push(new_request);
  }
  
  
  function create_item(bytes32 name) public restricted {
    
    items[name] = true;
    a_items.push(name);
  }
  
  
  function fillRequest(bytes32 _requestID, uint256 value) public restricted{    
    uint256 blockNumber = block.number;
    
    for (uint i=0; i<requests.length; i++) {
    	if(requests[i].requestID == _requestID){
		if(requests[i].expiration >= blockNumber && requests[i].cancelled == false){
		    Client client = Client(requests[i].callback);
		    client.value_callback(value);
		    
		    emit RequestFilled(requests[i].requestID, requests[i].callback, value);
		    
		    if(requests.length-1 == i){
		    	delete requests[i];
			requests.length--;
		    }
		    else{
		        requests[i] = requests[requests.length-1];
		        delete requests[requests.length-1];
		        requests.length--;
		    }
		}
		else{
		    if(requests.length-1 == i){
		    	delete requests[i];
			requests.length--;
		    }
		    else{
		        requests[i] = requests[requests.length-1];
		        delete requests[requests.length-1];
		        requests.length--;
		    }
		}
	}
    }
  }
  
  
  function fillRequest(bytes32 _requestID, uint256 value, uint256 begin, uint256 end) public restricted{    
    uint256 blockNumber = block.number;
    
    for (uint i=begin; i<requests.length && i<end; i++) {
    	if(requests[i].requestID == _requestID){
		if(requests[i].expiration >= blockNumber && requests[i].cancelled == false){
		    Client client = Client(requests[i].callback);
		    client.value_callback(value);
		    
		    requests[i].cancelled = true;
		}
		else{
		
		}
	}
    }
  }
  
  
  function get_items() public view returns(bytes32[] memory) {
    return a_items;
    
  }
  
  function get_requests() public view returns(request[] memory) {
    return requests;
    
  }
  
}
