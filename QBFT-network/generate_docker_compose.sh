#!/bin/bash

# Import node configurations
. nodes.conf

# Default values
IP_ADDRESS="172.16.239."
NODE_NAME="Node-"
IMAGE_NAME="quorumengineering/quorum"
PORT_8545=20000
PORT_8546=20001
NETWORK_NAME=quorum-test-net

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
for ((i=0; i<$NUM_VALIDATORS; i++))
do
    PORT_8545="$(expr $PORT_8546 + 1)"
    PORT_8546="$(expr $PORT_8546 + 2)"
    DATA_STORAGE="./$NODE_NAME$i/data/:/data"
    IP_ADDRESS_SUFFIX=$(($i + 2))
    
    node="  
    "validator-"$i:
      container_name: "validator-"$i
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
            ipv4_address: "$IP_ADDRESS$IP_ADDRESS_SUFFIX"
"
    #append node to docker-compose.yml
    CONTENT+=$node
    echo "$CONTENT" > "./docker-compose.yml"
done

for ((i=$NUM_VALIDATORS, j=0; i<$NUM_VALIDATORS+$NUM_MEMBERS; i++, j++))
do
    PORT_8545="$(expr $PORT_8546 + 1)"
    PORT_8546="$(expr $PORT_8546 + 2)"
    DATA_STORAGE="./$NODE_NAME$i/data/:/data"
    IP_ADDRESS_SUFFIX=$(($i + 2))
    
    node="  
    "member-"$i:
      container_name: "member-"$i
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
            ipv4_address: "$IP_ADDRESS$IP_ADDRESS_SUFFIX"

"
    #append node to docker-compose.yml
    CONTENT+=$node
    echo "$CONTENT" > "./docker-compose.yml"
done

# For each bootnode, copy files to the correct directories
for ((i=$NUM_VALIDATORS+$NUM_MEMBERS, j=0; i<$NUM_NODES; i++, j++))
do
    PORT_8545="$(expr $PORT_8546 + 1)"
    PORT_8546="$(expr $PORT_8546 + 2)"
    DATA_STORAGE="./$NODE_NAME$i/data/:/data"
    IP_ADDRESS_SUFFIX=$(($i + 2))
    
    node="  
    "bootnode-"$i:
      container_name: "bootnode-"$i
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
            ipv4_address: "$IP_ADDRESS$IP_ADDRESS_SUFFIX"

            
"
    #append node to docker-compose.yml
    CONTENT+=$node
    echo "$CONTENT" > "./docker-compose.yml"
done