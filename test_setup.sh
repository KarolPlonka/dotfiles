#!/bin/bash

# Test script to run setup.sh without GitHub operations and updates
# This script calls setup.sh with the --no-github and --no-update flags

# Exit immediately if a command exits with a non-zero status
set -e

# Get the directory where this script is located
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Check if setup.sh exists
if [ ! -f "$SCRIPT_DIR/setup.sh" ]; then
    echo "Error: setup.sh not found in $SCRIPT_DIR"
    exit 1
fi


echo "Running setup.sh in test mode (no GitHub operations, no updates)..."

# Execute setup.sh with the no-github and no-update flags
"$SCRIPT_DIR/setup.sh" --no-github --no-update

