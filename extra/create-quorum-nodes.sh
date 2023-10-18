#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <JavaScript script> <Number of repetitions>"
  exit 1
fi

# Store the JavaScript script and repetition count in variables
js_script="generate_node_details.js"
name="testnode-"
repetitions="$1"

# Loop to run the JavaScript script 'n' times
for ((i=1; i<=$repetitions; i++)); do
  node "$js_script" --name $name$i
done


