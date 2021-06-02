// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./AcriaMain.sol";


contract AcriaNode {

  struct request {
	bytes8 requestID;
	uint64 fee;
	uint64 expiration;
	uint32 id;
	uint32 max_gas;
	address callback;
	uint256 data;
	uint256 data_passthrough;
  }
  
  
  event RequestFilled(bytes32 requestID, address callback, uint256 fee, uint256 id);
  event RequestFilledError(bytes32 requestID, address callback, uint256 fee, uint256 id);
  event StakePaidOut(address indexed by, uint256 amount, uint256 period, uint256 token, uint256 total_token);
  
  address public immutable token_contract;
  
  address payable public immutable owner;
  address immutable master;
  request[] requests;
  uint256 public completedRequests = 0;
  
  uint256 withdrawable = 0;
  mapping(uint256 => uint256) public withdrawable_stake;
  mapping(uint256 => uint256) public period_staker;
  mapping(address => uint256) public staker;
  mapping(address => uint256) public staker_stake;
  uint256 public last_staker_added = 0;
  uint256 public previous_last_staker_added = 0;
  uint256 constant period_interval = 10000;//10 for local tests, 10000 for testnet (~2 days), 100000 for mainnet (~18 days)
  
  
  constructor(address payable _owner, address _token_contract) {
  	owner = _owner;
  	master = msg.sender;
  	token_contract = _token_contract;
  }


  modifier restricted() {
    require(
      msg.sender == owner,
      "Restricted to contract owner"
    );
    _;
  }
  
  
  function get_total_stake(uint256 period) public view returns (uint256){
  	if(period == 0){
  		return period_staker[last_staker_added];
  	}
  	else{
  		return period_staker[period];
  	}
  }


  function pump_fee(uint256 id) public payable {
  	require(msg.value < 10**18);
  	require(msg.value > 0);
  	require(msg.value + requests[id].fee < 10**18);
  	require(requests[id].expiration != 0);
  	
  	requests[id].fee += uint64(msg.value);
  }
  
  
  function create_request(bytes8 _requestID, address callback, uint256 _expire, uint32 max_gas) public payable {
    require(_expire > 100);
    require(msg.value < 10**18);
    require(_expire < 1000000);
    require(max_gas < 500000);
    
    request memory new_request;
    new_request.requestID = _requestID;
    new_request.fee = uint64(msg.value);
    new_request.expiration = uint64(block.number + _expire);
    new_request.callback = callback;
    new_request.id = uint32(requests.length);
    new_request.max_gas = uint32(max_gas);
    requests.push(new_request);
  }
  
  
  function create_request_with_data(bytes8 _requestID, address callback, uint256 _expire, uint32 max_gas, uint256 _data, uint256 _data_passthrough) public payable {
    require(_expire > 100);
    require(msg.value < 10**18);
    require(_expire < 1000000);
    require(max_gas < 500000);
    
    request memory new_request;
    new_request.requestID = _requestID;
    new_request.fee = uint64(msg.value);
    new_request.expiration = uint64(block.number + _expire);
    new_request.callback = callback;
    new_request.id = uint32(requests.length);
    new_request.max_gas = uint32(max_gas);
    if(_data != 0)
    	new_request.data = _data;
    if(_data_passthrough != 0)
    	new_request.data_passthrough = _data_passthrough;
    requests.push(new_request);
  }
  
  
  function withdraw() public restricted{
  	uint256 w = withdrawable;
  	withdrawable = 0;
  	
  	owner.transfer(w);
  }
  
  
  function start_stake(address initiator, uint256 balance) public {
  	require(msg.sender == token_contract, "Initiated by wrong contract");
  	require(staker[initiator] == 0, "Already staking");
  	require(balance > 0, "No Tokens");
  	
  	uint256 join_period = block.number/period_interval+1;
  	
  	staker[initiator] = join_period;
  	if(period_staker[join_period] == 0){
  		if(last_staker_added != 0 && last_staker_added != join_period){
  			period_staker[join_period] = period_staker[last_staker_added];
  		}
  	}
  	
  	uint256 bal = balance;
  	period_staker[join_period] += bal;
  	staker_stake[initiator] = bal;
  	
  	if(last_staker_added != join_period){
	  	previous_last_staker_added = last_staker_added;
	  	last_staker_added = join_period;
  	}
  }
  
  
  function cancel_stake_withdraw(address initiator) public {
  	if(block.number/period_interval-1 >= staker[initiator])
  		payout_stakes(initiator);
  	cancel_stake(initiator);
  }
  
  
  function cancel_stake(address initiator) public {
  	require(msg.sender == token_contract);
  	require(staker[initiator] != 0);
  	
  	uint256 join_period = block.number/period_interval+1;
  	
  	if(period_staker[block.number/period_interval] == 0){
  		if(last_staker_added == join_period){
	  		if(previous_last_staker_added != 0){
	  			period_staker[block.number/period_interval] = period_staker[previous_last_staker_added];
	  		}
  		}
  		else{
  			if(last_staker_added != 0){
	  			period_staker[block.number/period_interval] = period_staker[last_staker_added];
	  		}
  		}
  	}
  	if(period_staker[join_period] == 0){
  		if(last_staker_added != 0 && last_staker_added != join_period){
  			period_staker[join_period] = period_staker[last_staker_added];
  		}
  	}
  	
  	if(last_staker_added != join_period){
	  	previous_last_staker_added = last_staker_added;
	  	last_staker_added = join_period;
  	}
  	
  	uint256 bal = staker_stake[initiator];
  	period_staker[join_period] -= bal;
  	if(staker[initiator] <= join_period-1){
  		period_staker[join_period-1] -= bal;
  		previous_last_staker_added = join_period-1;
  		
  		if(period_staker[join_period-1] == 0){
  			withdrawable += withdrawable_stake[join_period-1];
  		}
  	}
  	staker_stake[initiator] = 0;
  	
  	staker[initiator] = 0;
  	
  }
  
  
  function payout_stake(uint256 period, address initiator) private returns (uint256){
  	if(period_staker[period] == 0){
  		if(period_staker[period-1] != 0){
  			period_staker[period] = period_staker[period-1];
  		}
  	}
  	
  	if(withdrawable_stake[period] > 0){
	  	uint256 user_stake = staker_stake[initiator];
	  	
	  	uint256 payout = withdrawable_stake[period]*user_stake/period_staker[period];

	  	emit StakePaidOut(initiator, payout, period, user_stake, period_staker[period]);
	  	
	  	return payout;
  	}
  	else{
  		return 0;
  	}
  }
  
  
  function payout_stakes(address initiator) public {
  	require(staker[initiator] != 0, "Not a staker");
  	require(block.number/period_interval-1 >= staker[initiator], "No full cicle staked");
  	
  	uint256 total_payout = 0;
  	
  	for(uint256 i = staker[initiator]; i<=block.number/period_interval-1;i++){
  		total_payout += payout_stake(i, initiator);
  	}
  	
  	staker[initiator] = block.number/period_interval;
	  	
	payable(initiator).transfer(total_payout);
  }
  
  
  function fillRequest(bytes8 _requestID, uint256 value, uint256 i) public restricted{    
    	require(requests[i].requestID == _requestID);
    	
    	bool staker_is_active = false;
    	if(period_staker[block.number/period_interval] == 0){
  		if(last_staker_added == block.number/period_interval+1){
	  		if(previous_last_staker_added != 0){
	  			if(period_staker[previous_last_staker_added] != 0)
	  				staker_is_active = true;
	  		}
  		}
  		else{
  			if(last_staker_added != 0){
	  			if(period_staker[last_staker_added] != 0)
	  			 staker_is_active = true;
	  		}
  		}
  	}
  	else{
  		staker_is_active = true;
  	}
    	
		if(requests[i].expiration >= block.number){
		    address callback = requests[i].callback;
		    uint256 fee = requests[i].fee/10*8;
		    uint32 max_gas = requests[i].max_gas;
		    uint256 data = requests[i].data;
		    uint256 data_passthrough = requests[i].data_passthrough;
		    
		    if(staker_is_active)
		    	withdrawable_stake[block.number/period_interval] += requests[i].fee - fee;
		    else
		    	fee += requests[i].fee - fee;
			    	
	            withdrawable += fee;
		    
		    delete requests[i];
		    completedRequests++;
		    
		    bool success;
		    if(data == 0 && data_passthrough == 0)
		    	(success, ) = callback.call{gas:max_gas}(abi.encodeWithSignature("value_callback(uint256)", value));
		    else
		    	(success, ) = callback.call{gas:max_gas}(abi.encodeWithSignature("value_callback(uint256,uint256,uint256)", value, data, data_passthrough));
		    	
		    if(!success) {
			    emit RequestFilledError(_requestID, callback, fee, i);
		    }
		    else{
		    	emit RequestFilled(_requestID, callback, fee, i);
		    }
		    
		 
		}
		else{
		    if(staker_is_active)
		    	withdrawable_stake[block.number/period_interval] += requests[i].fee;
		    else
		        withdrawable += requests[i].fee;
		    delete requests[i];
		}
	
    }
  
  
  function get_requests() public view returns(request[] memory) {
    return requests;
    
  }
  

  function get_withdrawable() public view returns(uint256) {
    return withdrawable;
    
  }
  
  
}
