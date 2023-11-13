#!/bin/bash

NUM_NODES=5

export ADDRESS=$(grep -o '"address": *"[^"]*"' Node-0/data/keystore/accountKeystore | grep -o '"[^"]*"$' | sed 's/"//g')
export PRIVATE_CONFIG=ignore

# Start node 0
cd Node-0
echo "geth --datadir data \\
    --networkid 1337 --nodiscover --verbosity 5 \\
    --syncmode full \\
    --istanbul.blockperiod 5 --mine --miner.threads 1 --miner.gasprice 0 --emitcheckpoints \\
    --http --http.addr 127.0.0.1 --http.port 22000 --http.corsdomain \"*\" --http.vhosts \"*\" \\
    --ws --ws.addr 127.0.0.1 --ws.port 32000 --ws.origins \"*\" \\
    --http.api admin,eth,debug,miner,net,txpool,personal,web3,istanbul \\
    --ws.api admin,eth,debug,miner,net,txpool,personal,web3,istanbul \\
    --unlock 0x${ADDRESS} --allow-insecure-unlock --password ./data/keystore/accountPassword \\
    --port 30300" > start_node_0.sh
cd ..



# Start the rest of the nodes
for ((i=1; i<$NUM_NODES; i++))
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
    --unlock ${ADDRESS} --allow-insecure-unlock --password ./data/keystore/accountPassword \\
    --port ${PORT}" > start_node_$i.sh
    cd ..
done

#for ((i=0; i<$NUM_NODES; i++))
#do
#    cd Node-$i
#    bash start_node_$i.sh &
#    cd ..
#done