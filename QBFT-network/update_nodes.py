import os
import json

ARTIFACTS_PATH = os.path.join(os.getcwd(), 'artifacts')
GOQUORUM_PATH = os.path.join(ARTIFACTS_PATH, 'goQuorum')
STATIC_NODES_PATH = os.path.join(GOQUORUM_PATH, 'static-nodes.json')

def update_nodes():
    with open(STATIC_NODES_PATH, 'r') as f:
        data = json.load(f)

    new_data = []
    for idx, node in enumerate(data):
        enode, node_ip = node.split('@')
        node_ip = f"172.16.239.{2+idx}:{30303}?discport=0&raftport={53000}"
        new_data.append(enode + '@' + node_ip)
    
    with open(STATIC_NODES_PATH, 'w') as f:
        json.dump(new_data, f, indent=4)

def main():
    update_nodes()

if __name__ == '__main__':
    main()