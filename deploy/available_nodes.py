import json
from web3 import Web3, HTTPProvider
import os
from os.path import join, dirname
from dotenv import load_dotenv

load_dotenv(join(dirname(__file__), '.env'))

web3 = Web3(HTTPProvider(os.environ.get("WEB3_HTTP_PROVIDER_URL")))
web3.eth.defaultAccount = web3.eth.accounts[0]

with open('../build/contracts/AcriaMain.json') as file:
    contract_json = json.load(file)
    contract_abi = contract_json['abi']

AcriaMain = web3.eth.contract(address=os.environ.get("ACRIA_MAIN_ADDRESS"), abi=contract_abi)

message = AcriaMain.functions.get_nodes().call()
print(message)
