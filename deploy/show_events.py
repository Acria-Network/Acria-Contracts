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

web3.eth.defaultAccount = web3.eth.accounts[0]

with open('../build/contracts/AcriaNode.json') as file:
    contract_json = json.load(file)
    contract_abi = contract_json['abi']

AcriaNode = web3.eth.contract(address=os.environ.get("ACRIA_NODE_ADDRESS"), abi=contract_abi)
event_filter = AcriaNode.events.RequestFilled.createFilter(fromBlock=1)
events0 = event_filter.get_all_entries()
print(events0)
