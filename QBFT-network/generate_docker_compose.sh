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
IP_ADDRESS_FILE=""
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

# For each validator, copy files to the correct directories
for ((i=0,  j=0; i<$NUM_VALIDATORS; i++, j++))
do
    PORT_8545="$(expr $PORT_8546 + 1)"
    PORT_8546="$(expr $PORT_8546 + 2)"
    DATA_STORAGE="./nodes/validator-$j/data/:/data"
    IP_ADDRESS_SUFFIX=$(($i + 2))
    
    node="  
    "validator-"$j:
      container_name: "validator-"$j
      image: $IMAGE_NAME
      ports:
        - $PORT_8545:8545/tcp
        - $PORT_8546:8546/tcp
        - 30303
        - 9545

      entrypoint: ./docker-entrypoint.sh
      environment:
        - PRIVATE_CONFIG=ignore
      volumes:
        - ./docker-entrypoint.sh:/docker-entrypoint.sh
        - ./scripts/add_member.sh:/data/add_member.sh
        - $DATA_STORAGE
      networks:
        quorum-test-net:
            ipv4_address: "$IP_ADDRESS$IP_ADDRESS_SUFFIX"
"
    #append ip address to ip address file
    IP_ADDRESS_FILE+="validator-$j:$IP_ADDRESS$IP_ADDRESS_SUFFIX\n"
    echo -e "$IP_ADDRESS_FILE" > "./node_ip_addresses.txt"
    #append node to docker-compose.yml
    CONTENT+=$node
    echo "$CONTENT" > "./docker-compose.yml"
done

# For each bootnode, copy files to the correct directories
for ((i=$NUM_VALIDATORS, j=0; i<$NUM_VALIDATORS+$NUM_BOOTNODES; i++, j++))
do
    PORT_8545="$(expr $PORT_8546 + 1)"
    PORT_8546="$(expr $PORT_8546 + 2)"
    DATA_STORAGE="./nodes/bootnode-$j/data/:/data"
    IP_ADDRESS_SUFFIX=$(($i + 2))
    
    node="  
    "bootnode-"$j:
      container_name: "bootnode-"$j
      image: $IMAGE_NAME
      ports:
        - $PORT_8545:8545/tcp
        - $PORT_8546:8546/tcp
        - 30303
        - 9545

      entrypoint: ./docker-entrypoint.sh
      environment:
        - PRIVATE_CONFIG=ignore
      volumes:
        - ./docker-entrypoint.sh:/docker-entrypoint.sh
        - ./scripts/add_member.sh:/data/add_member.sh
        - $DATA_STORAGE
      networks:
        quorum-test-net:
            ipv4_address: "$IP_ADDRESS$IP_ADDRESS_SUFFIX"
"
    #append node to docker-compose.yml
    IP_ADDRESS_FILE+="bootnode-$j:$IP_ADDRESS$IP_ADDRESS_SUFFIX\n"
    echo -e "$IP_ADDRESS_FILE" > "./node_ip_addresses.txt"
    CONTENT+=$node
    echo "$CONTENT" > "./docker-compose.yml"
done

# For each member, copy files to the correct directories
for ((i=$NUM_VALIDATORS+$NUM_BOOTNODES, j=0; i<$NUM_NODES; i++, j++))
do
    PORT_8545="$(expr $PORT_8546 + 1)"
    PORT_8546="$(expr $PORT_8546 + 2)"
    DATA_STORAGE="./nodes/member-$j/data/:/data"
    IP_ADDRESS_SUFFIX=$(($i + 2))
    
    node="  
    "member-"$j:
      container_name: "member-"$j
      image: $IMAGE_NAME
      ports:
        - $PORT_8545:8545/tcp
        - $PORT_8546:8546/tcp
        - 30303
        - 9545

      entrypoint: ./docker-entrypoint.sh
      environment:
        - PRIVATE_CONFIG=ignore
      volumes:
        - ./docker-entrypoint.sh:/docker-entrypoint.sh
        - ./scripts/add_member.sh:/data/add_member.sh
        - $DATA_STORAGE
      networks:
        quorum-test-net:
            ipv4_address: "$IP_ADDRESS$IP_ADDRESS_SUFFIX"

"
    #append ip address to ip address file
    IP_ADDRESS_FILE+="member-$j:$IP_ADDRESS$IP_ADDRESS_SUFFIX\n"
    echo -e "$IP_ADDRESS_FILE" > "./node_ip_addresses.txt"
    #append node to docker-compose.yml
    CONTENT+=$node
    echo "$CONTENT" > "./docker-compose.yml"
done