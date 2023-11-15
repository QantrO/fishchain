#!/bin/bash

# Default values
IP_ADDRESS="172.16.239."
IP_ADDRESS_SUFFIX=2
NODE_NAME="Node-"
CONTAINER_NAME="validator-"
IMAGE_NAME="quorumengineering/quorum"
DATA_STORAGE=""
PORT_8545=20000
PORT_8546=20001
NETWORK_NAME=quorum-test-net
REPETITIONS=2

CONTENT="---
version: '3.6'

networks:
  $NETWORK_NAME:
    name: $NETWORK_NAME
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.16.239.0/24

services:
"


# Loop to run the JavaScript script 'n' times
for ((i=0; i<$REPETITIONS; i++)); do
    PORT_8545="$(expr $PORT_8546 + 1)"
    PORT_8546="$(expr $PORT_8546 + 2)"
    DATA_STORAGE="./$NODE_NAME$i/data/:/data"
    IP_ADDRESS_loc="$IP_ADDRESS$(expr $i + $IP_ADDRESS_SUFFIX)"
    
    node="  
    $CONTAINER_NAME$i:
      container_name: $CONTAINER_NAME$i
      image: $IMAGE_NAME
      ports:
        - $PORT_8545:8545/tcp
        - $PORT_8546:8546/tcp
        - 30303
      entrypoint: ./docker-entrypoint.sh
      environment:
        - PRIVATE_CONFIG=ignore
      volumes:
        - ./docker-entrypoint.sh:/docker-entrypoint.sh
        - $DATA_STORAGE
      networks:
        quorum-test-net:
            ipv4_address: $IP_ADDRESS_loc
"
    #append node to docker-compose.yml
    CONTENT+=$node
    echo "$CONTENT" > "./docker-compose.yml"
done
