#!/bin/bash
set -e

# Start snapd service
service snapd start

# Wait for snapd to be ready
while ! snap version > /dev/null 2>&1; do
    echo "Waiting for snapd to be ready..."
    sleep 2
done

# Install snap packages
echo "Installing snap packages..."
snap install nvim --classic

