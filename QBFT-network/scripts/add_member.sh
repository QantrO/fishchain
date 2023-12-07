#!/bin/bash
echo "Adding new member to Quorum network"
permissioned_nodes="data/permissioned-nodes.json"

# Check if the file exists
if [ ! -e "$permissioned_nodes" ]; then
    echo "File not found"
    exit 1
fi

# Read permissioned_nodes into a variable
json_data=$(cat "$permissioned_nodes")

# Append a new item to the list
new_member=$1
new_entry='    "'$new_member'"'

# Add the new item to the end of the list
json_data="${json_data%]*},$new_entry]"

# Save the updated JSON data back to the file
echo "$json_data" > "$permissioned_nodes"
echo "Finished"
