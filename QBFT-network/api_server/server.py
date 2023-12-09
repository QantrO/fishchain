import json
import flask
import subprocess
from web3 import Web3

app = flask.Flask(__name__)


@app.route('/')
def index():
    enode_address = get_enode_from_member()
    return flask.render_template('index.html', enode_address=enode_address)

@app.route('/add_node')
def add_node_dev():
    # Add node to the network
    rc = subprocess.call(["sh", "../scripts/add_member_single_node.sh"])

    return flask.render_template('index.html')

def add_node_prod():
    """ Add node to the network, by interacting with the smart contract.

        Not tested yet.
     """
    enode = get_member_details()
    subprocess.call(["docker", "exec", "-it", "bootnode-0", "sh", "/data/add_member.sh", f"{enode}"])

@app.route('/add_node_all')
def add_node_all():
    # Add node to the network
    rc = subprocess.call(["sh", "../scripts/add_member_to_network.sh"])

    return flask.render_template('index.html')

def get_enode_from_member():
    rc = subprocess.run(["sh", "../scripts/get_enode.sh"], capture_output=True, text=True)
    return rc.stdout.strip()

def get_member_details():
    """ Retrieve the member details from the smart contract. 
    Inspired by
    https://cryptomarketpool.com/read-solidity-smart-contract-data-using-web3-py-in-python/"""
    url = 'http://localhost:8545'
    web3 = Web3(Web3.HTTPProvider(url))
    with open('../contracts/OnboardingMember.json') as f:
        abi = json.load(f)

    # Change this to the contract's address
    address = "smart_contract_address"
    contract = web3.eth.contract(address=address, abi=abi)
    # Listen to the contract
    member_details = contract.functions.getMemberDetails().call()
    enode = f"enode://{member_details[1]}@{member_details[0]}:30303?discport=0&raftport=53000"
    return enode


def main():
    app.run(host="localhost", port=5000)

if __name__ == '__main__':
    main()