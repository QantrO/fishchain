new_member_path="../new_member/data/geth/nodekey"
new_member_key=$(cat "$new_member_path")

new_member_pub=$(bootnode -nodekeyhex $new_member_key -writeaddress)
new_member="enode://$new_member_pub@172.16.239.50:30303?discport=0&raftport=53000"

docker exec -it "bootnode-0" sh "/data/add_member.sh" "$new_member"