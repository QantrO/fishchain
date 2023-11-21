#!/bin/sh

geth --datadir data init data/genesis.json

cp ./data/nodekey ./data/geth/nodekey;
cp ./data/keystore/accountKeystore /data/keystore/key;

export ADDRESS=$(grep -o '"address": *"[^"]*"' ./data/keystore/accountKeystore | grep -o '"[^"]*"$' | sed 's/"//g')

exec geth \
    --datadir /data \
    --networkid 1337 --nodiscover --verbosity 5 \
    --syncmode full \
    --istanbul.blockperiod 5 --mine --miner.threads 1 --miner.gasprice 0 --emitcheckpoints \
    --http --http.addr 127.0.0.1 --http.port 8545 --http.corsdomain "*" --http.vhosts "*" \
    --ws --ws.addr 127.0.0.1 --ws.port 8546 --ws.origins "*" \
    --http.api admin,eth,debug,miner,net,txpool,personal,web3,istanbul \
    --ws.api admin,eth,debug,miner,net,txpool,personal,web3,istanbul \
    --identity ${HOSTNAME}-"qbft" \
    --unlock ${ADDRESS} \
    --allow-insecure-unlock --password ./data/keystore/accountPassword \
    --port 30303 \
    --maxpeers 100