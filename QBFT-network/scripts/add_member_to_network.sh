new_member_path="../new_member/data/geth/nodekey"
new_member_key=$(cat "$new_member_path")

new_member_pub=$(bootnode -nodekeyhex $new_member_key -writeaddress)
new_member="enode://$new_member_pub@172.16.239.50:30303?discport=0&raftport=53000"

container_ids=$(docker ps --format "{{.Names}}" --no-trunc)

for container_id in $container_ids; do
    echo $container_id 
    docker exec -it "$container_id" sh "/data/add_member.sh" "$new_member"
done