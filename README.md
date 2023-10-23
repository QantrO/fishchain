# fishchain

## Initialization

- Create the directories **data** and **nodes** inside quorum_nodes_local
- Copy the data directory from `config/goquorum/data` from the goquorum-dev-quickstart into the newly create data directory
- CD to **fishchain/extra** and run npm install
- Might need to run **chmod +x generate-nodes.sh** to add execute permissions
- run **./generate-nodes.sh <num_nodes>**
- CD to **fishchain/quorum_nodes_local** and run **docker compose up --build --detach**
- To shutdown **docker compose down --rmi all**