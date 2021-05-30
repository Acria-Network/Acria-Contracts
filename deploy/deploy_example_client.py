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

web3.eth.defaultAccount = web3.eth.accounts[2]

with open('../build/contracts/ClientExample4.json') as file:
    contract_json_client = json.load(file)
    contract_abi_client = contract_json_client['abi']
    contract_bytecode_client = contract_json_client['bytecode']

example_client3 = web3.eth.contract(abi=contract_abi_client, bytecode=contract_bytecode_client)
tx_hash = example_client3.constructor(Web3.toChecksumAddress(os.environ.get("ACRIA_NODE_ADDRESS"))).transact()
tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)
example_client3_address = tx_receipt.contractAddress
print(example_client3_address)
