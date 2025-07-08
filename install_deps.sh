#!/bin/bash

# Check if sudo is available and user has sudo privileges
if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    echo "Using sudo for package management..."
    SUDO_CMD="sudo"
else
    echo "Running without sudo (assuming root or no sudo available)..."
    SUDO_CMD=""
fi

# Update package lists and upgrade system
$SUDO_CMD apt update && $SUDO_CMD apt upgrade -y

# Install packages
$SUDO_CMD apt install -y \
    sudo \
    curl \
    wget \
    vim \
    git \
    gh \
    build-essential \
    sudo \
    snapd \
    cmake \
    ca-certificates \
    tmux \
    gcc \
    xclip \
    ripgrep \
    python3-venv \
    xdg-utils \
    bash

# Clean up
$SUDO_CMD apt clean


