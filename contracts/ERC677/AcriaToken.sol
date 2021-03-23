// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

import "./ERC677Token.sol";

contract AcriaToken is ERC677Token {
	//mapping (address => bool) private transfer_blocked;
	//mapping (address => uint256) private _balances;

	function start_staking(address _contract) public{
		require(transfer_blocked[msg.sender] != true, "ERC20: transfer blocked, currently staking");
		
		transfer_blocked[msg.sender] = true;
		
		AcriaNode acria_node = AcriaNode(_contract);
		acria_node.start_stake(msg.sender, balanceOf(msg.sender));
	}
	
	function stop_staking(address _contract) public{
		require(transfer_blocked[msg.sender] == true, "ERC20: transfer not blocked, currently not staking");
		
		transfer_blocked[msg.sender] = false;
		
		AcriaNode acria_node = AcriaNode(_contract);
		acria_node.cancel_stake_withdraw(msg.sender);
	}
}
