#!/bin/bash

NUM_VALIDATORS=5
NUM_BOOTNODES=1
NUM_MEMBERS=1
NUM_NODES=$((NUM_VALIDATORS+NUM_BOOTNODES+NUM_MEMBERS))

# For each node, create a directory "Node-{i}/data/keystore"

for ((i=0; i<$NUM_NODES; i++))
do
    mkdir -p Node-$i/data/keystore
done

# Create genesis file and node keys
npm install quorum-genesis-tool
npx quorum-genesis-tool --consensus qbft --chainID 1337 --blockperiod 5 --requestTimeout 10 --epochLength 30000 --difficulty 1 --gasLimit '0xFFFFFF' --coinbase '0x0000000000000000000000000000000000000000' --validators $NUM_VALIDATORS --members $NUM_MEMBERS --bootnodes $NUM_BOOTNODES --outputPath 'artifacts'

# Move generated files to the correct directories
echo "Moving generated files to the correct directories"
mv artifacts/*/* artifacts

# Update the IP and port numbers for all initial validators
echo "Updating the IP and port numbers for all initial validators"
python3 update_nodes.py

# Copy the static-nodes.json file to the permissioned-nodes.json file
echo "Copying the static-nodes.json file to the permissioned-nodes.json file"
cp artifacts/goQuorum/static-nodes.json artifacts/goQuorum/permissioned-nodes.json


# For each validator, copy files to the correct directories
echo "Copying files to the correct directories"
for ((i=0; i<$NUM_VALIDATORS; i++))
do
    cp artifacts/goQuorum/static-nodes.json artifacts/goQuorum/genesis.json Node-$i/data
    cp artifacts/validator$i/nodekey* artifacts/validator$i/address Node-$i/data
    cp artifacts/validator$i/account* Node-$i/data/keystore
done

# For each member, copy files to the correct directories
for ((i=$NUM_VALIDATORS, j=0; i<$NUM_VALIDATORS+$NUM_MEMBERS; i++, j++))
do
    cp artifacts/goQuorum/static-nodes.json artifacts/goQuorum/genesis.json Node-$i/data
    cp artifacts/member$j/nodekey* artifacts/member$j/address Node-$i/data
    cp artifacts/member$j/account* Node-$i/data/keystore
done

# For each bootnode, copy files to the correct directories
for ((i=$NUM_VALIDATORS+$NUM_MEMBERS, j=0; i<$NUM_NODES; i++, j++))
do
    cp artifacts/goQuorum/static-nodes.json artifacts/goQuorum/genesis.json Node-$i/data
    cp artifacts/bootnode$j/nodekey* artifacts/bootnode$j/address Node-$i/data
    cp artifacts/bootnode$j/account* Node-$i/data/keystore
done

# In each node directory, initialize the node
echo "Initializing the nodes"
for ((i=0; i<$NUM_NODES; i++))
do
    cd Node-$i
    geth --datadir data init data/genesis.json
    cd ..
done

# Create start_node_{i}.sh for all nodes
for ((i=0; i<$NUM_NODES; i++))
do
    export ADDRESS=$(grep -o '"address": *"[^"]*"' Node-$i/data/keystore/accountKeystore | grep -o '"[^"]*"$' | sed 's/"//g')
    HTTP_PORT=$((22000+$i))
    WS_PORT=$((32000+$i))
    PORT=$((30300+$i))
    cd Node-$i
    echo "geth --datadir data \\
    --networkid 1337 --nodiscover --verbosity 5 \\
    --syncmode full \\
    --istanbul.blockperiod 5 --mine --miner.threads 1 --miner.gasprice 0 --emitcheckpoints \\
    --http --http.addr 127.0.0.1 --http.port ${HTTP_PORT} --http.corsdomain \"*\" --http.vhosts \"*\" \\
    --ws --ws.addr 127.0.0.1 --ws.port ${WS_PORT} --ws.origins \"*\" \\
    --http.api admin,eth,debug,miner,net,txpool,personal,web3,istanbul \\
    --ws.api admin,eth,debug,miner,net,txpool,personal,web3,istanbul \\
    --unlock 0x${ADDRESS} --allow-insecure-unlock --password ./data/keystore/accountPassword \\
    --port ${PORT}" > start_node_$i.sh
    cd ..
done
