#!/bin/bash

# Default values
IP_ADDRESS="172.16.239."
NODE_NAME="testnode-"
CONTAINER_NAME="testnode-"
KEY_STORAGE="./nodes/$NODE_NAME:/config/keys"
PORT_8545=20009
PORT_8546=20010

# Generator script
JS_SCRIPT="generate_node_details.js"
DIR_NAME="testnode"
REPETITIONS=$1

# Pathing
FILENAME="../quorum_nodes_local/docker-compose-template.yml"
CONTENT=$(<"$FILENAME")


# Loop to run the JavaScript script 'n' times
for ((i=1; i<=$REPETITIONS; i++)); do
    NODE_NAME_loc="$NODE_NAME$i"
    DIR_NAME_loc="$DIR_NAME$i"
    PORT_8545="$(expr $PORT_8546 + 1)"
    PORT_8546="$(expr $PORT_8546 + 2)"
    KEY_STORAGE="./nodes/$DIR_NAME_loc:/config/keys"
    IP_ADDRESS_SUFFIX=60
    IP_ADDRESS_loc="$IP_ADDRESS$(expr $i + $IP_ADDRESS_SUFFIX)"
    
    node="  $NODE_NAME_loc:
    <<: *quorum-def
    container_name: $NODE_NAME_loc
    ports:
      - $PORT_8545:8545/tcp
      - $PORT_8546:8546/tcp
      - 30303
      - 9545
    environment:
      - GOQUORUM_GENESIS_MODE=standard
      - PRIVATE_CONFIG=ignore
    volumes:
      - .:/quorum
      - $KEY_STORAGE
    networks:
      quorum-dev-quickstart:
        ipv4_address: $IP_ADDRESS_loc

"
    #append node to docker-compose.yml
    CONTENT+=$node
    echo "$CONTENT" > "../quorum_nodes_local/docker-compose.yml"
    node "$JS_SCRIPT" --name $DIR_NAME_loc
done
