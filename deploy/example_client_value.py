import json
from web3 import Web3, HTTPProvider

# truffle development blockchain address
blockchain_address = 'http://127.0.0.1:9545'
web3 = Web3(HTTPProvider(blockchain_address))

web3.eth.defaultAccount = web3.eth.accounts[0]

compiled_contract_path = '../build/contracts/ExampleClient.json'

deployed_contract_address = '0xd251B35B29B50DC517515b05e496FAf46bbf0572'

with open(compiled_contract_path) as file:
    contract_json = json.load(file)
    contract_abi = contract_json['abi']

ClientExample = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

transaction = ClientExample.functions.get_lastValue().call()

print(transaction)
