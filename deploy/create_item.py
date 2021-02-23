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

zBytes = "BTC/USD"
len1 = len(zBytes)

if len1 > 32:
    print('input string length: '+ str(len1)+ ' is too long')
    zBytes32 = zBytes[:32]
else:
    print('input string length: '+ str(len1)+ ' is too short')
    print('More characters needed: '+ str(32-len1))
    zBytes32 = zBytes.ljust(32, ' ')

print('zBytes32 = '+ str(zBytes32)+ ' and its length: '+ str(len(zBytes32)))
xBytes32 = bytes(zBytes32, 'utf-8')
print('xBytes32 = '+ str(xBytes32))

transaction = AcriaNode.functions.create_item(xBytes32).transact()

print(transaction)
