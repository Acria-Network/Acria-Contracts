import json
from web3 import Web3, HTTPProvider

# truffle development blockchain address
blockchain_address = 'http://127.0.0.1:9545'
web3 = Web3(HTTPProvider(blockchain_address))

web3.eth.defaultAccount = web3.eth.accounts[0]

compiled_contract_path = '../build/contracts/AcriaMain.json'

deployed_contract_address = '0x25339522Df3d615ed729F6c0380B94E93B4eAE64'

with open(compiled_contract_path) as file:
    contract_json = json.load(file)
    contract_abi = contract_json['abi']

AcriaMain = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

message = AcriaMain.functions.get_nodes().call()

print(message)
