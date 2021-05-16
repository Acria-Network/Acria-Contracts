import json
from web3 import Web3, HTTPProvider, IPCProvider
from web3.middleware import geth_poa_middleware
import os
from os.path import join, dirname
from dotenv import load_dotenv

load_dotenv(join(dirname(__file__), '.env'))

if(os.environ.get("WEB3_USE_IPC") == False):
    web3 = Web3(HTTPProvider(os.environ.get("WEB3_HTTP_PROVIDER_URL")))
else:
    web3 = Web3(IPCProvider(os.environ.get("WEB3_IPC_PROVIDER_URL")))

if(os.environ.get("WEB3_MIDDLEWARE_ONION_INJECT")):    
    web3.middleware_onion.inject(geth_poa_middleware, layer=0)

web3.eth.defaultAccount = web3.eth.accounts[1]

with open('../build/contracts/AcriaMain.json') as file:
    contract_json = json.load(file)
    contract_abi = contract_json['abi']
    contract_bytecode = contract_json['bytecode']

with open('../build/contracts/AcriaToken.json') as file:
    contract_json_token = json.load(file)
    contract_abi_token = contract_json_token['abi']
    contract_bytecode_token = contract_json_token['bytecode']

acria_token = web3.eth.contract(abi=contract_abi_token, bytecode=contract_bytecode_token)
tx_hash = acria_token.constructor().transact()
tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)
acria_token_address = tx_receipt.contractAddress
print(acria_token_address)

acria_main = web3.eth.contract(abi=contract_abi, bytecode=contract_bytecode)
tx_hash = acria_main.constructor(acria_token_address).transact()
tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)
acria_main_address = tx_receipt.contractAddress
print(acria_main_address)