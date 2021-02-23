import json
from web3 import Web3, HTTPProvider

# truffle development blockchain address
blockchain_address = 'http://127.0.0.1:9545'
web3 = Web3(HTTPProvider(blockchain_address))

web3.eth.defaultAccount = web3.eth.accounts[0]

compiled_contract_path = '../build/contracts/AcriaNode.json'

deployed_contract_address = '0xD4cA7302185a7346557709eFf49d05536B766d4A'

with open(compiled_contract_path) as file:
    contract_json = json.load(file)
    contract_abi = contract_json['abi']

AcriaNode = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

event_filter = AcriaNode.events.RequestFilled.createFilter(fromBlock=1)
a = event_filter.get_all_entries()

print(a)
