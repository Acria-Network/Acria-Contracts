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

transaction = AcriaNode.functions.fillRequest(xBytes32, 400).transact()
contract_data = AcriaNode.functions.fillRequest(xBytes32, 400).buildTransaction(transaction)