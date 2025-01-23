#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Log file
LOG_FILE="dotfiles.log"

# Function to log and execute commands
run_command() {
    local command="$1"
    local description="$2"

    # Print the command description
    echo "Running: $description..."

    # Execute the command, redirect output to log file, and capture errors
    if eval "$command" >> "$LOG_FILE" 2>&1; then
        echo "Finished: $description."
    else
        # Print error to screen and exit
        echo "Error: Failed to execute '$description'. Check $LOG_FILE for details."
        exit 1
    fi
}

# Clear the log file
> "$LOG_FILE"

# Update and upgrade the system
run_command "sudo apt update -y" "System update"
run_command "sudo apt upgrade -y" "System upgrade"

# Install necessary packages
run_command "sudo apt install gh neovim tmux nodejs rsync gcc -y" "Install required packages"

# Authenticate with GitHub CLI
run_command "gh auth login" "GitHub CLI authentication"

# Create directories and clone repositories
run_command "mkdir -p ~/.config/tmux/plugins/catppuccin" "Create tmux config directory"

run_command "git clone https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux" "Clone Catppuccin tmux theme"

run_command "git clone https://github.com/tmux-plugins/tmux-battery ~/.config/tmux/plugins/tmux-battery" "Clone tmux-battery plugin"

run_command "git clone https://github.com/tmux-plugins/tmux-cpu ~/.config/tmux/plugins/tmux-cpu" "Clone tmux-cpu plugin"

run_command "git clone https://github.com/ofirgall/tmux-window-name ~/.config/tmux/plugins/tmux-window-name" "Clone tmux-window-name plugin"

# Sync files
run_command "rsync -a --update --ignore-existing src/ ~/" "Sync files from src to home directory"

# Install packer.nvim
run_command "git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim" "Install packer.nvim"

# Install Copilot.vim
run_command "git clone https://github.com/github/copilot.vim.git ~/.config/nvim/pack/github/start/copilot.vim" "Install Copilot.vim"

# Move and configure Neovim files
run_command "mv ~/.config/nvim/after ~/.config/nvim/.after" "Move Neovim after directory"

run_command "nvim -c 'so ~/.config/nvim/lua/k-roll/packer.lua' -c 'PackerSync' -c 'q!'" "Sync Neovim plugins"

run_command "mv ~/.config/nvim/.after ~/.config/nvim/after" "Restore Neovim after directory"

# Setup Copilot
run_command "nvim -c 'Copilot setup' -c 'q!'" "Setup Copilot"

echo "Script completed successfully. Logs saved to $LOG_FILE."
