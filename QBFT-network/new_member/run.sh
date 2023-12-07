container_name=new_member
network=quorum-test-net
ip_address=172.16.239.50

# Create IP address of bootnode
bootnode_path="../nodes/bootnode-0/data/nodekey.pub"
boot_pub_key=$(cat "$bootnode_path")
boot_ip=$(grep 'bootnode-0' ../node_ip_addresses.txt | cut -d':' -f2)
bootnode="enode://$boot_pub_key@$boot_ip:30303"

# Fetch genesis file
cp ../nodes/bootnode-0/data/genesis.json data/

docker run -v /root/github/fishchain/QBFT-network/new_member/data:/data -w /data -e PRIVATE_CONFIG=ignore quorumengineering/quorum --datadir /data init genesis.json

docker run -v /root/github/fishchain/QBFT-network/new_member/data:/data -w /data --rm --network $network --ip $ip_address -e PRIVATE_CONFIG=ignore --name $container_name quorumengineering/quorum --datadir /data --bootnodes "$bootnode"
