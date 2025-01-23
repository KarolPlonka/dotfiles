#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update and upgrade the system
sudo apt update -y
sudo apt upgrade -y

# Install necessary packages
sudo apt install gh neovim tmux nodejs rsync gcc xclip ripgrep -y

# Authenticate with GitHub CLI
gh auth login

# Create directories and clone repositories
mkdir -p ~/.config/tmux/plugins/catppuccin

git clone https://github.com/catppuccin/tmux.git \
    ~/.config/tmux/plugins/catppuccin/tmux

git clone https://github.com/tmux-plugins/tmux-battery \
    ~/.config/tmux/plugins/tmux-battery

git clone https://github.com/tmux-plugins/tmux-cpu \
    ~/.config/tmux/plugins/tmux-cpu

git clone https://github.com/ofirgall/tmux-window-name \
    ~/.config/tmux/plugins/tmux-window-name

# Sync files
rsync -a --update --ignore-existing src/ ~/

# Install packer.nvim
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# Install Copilot.vim
git clone https://github.com/github/copilot.vim.git \
  ~/.config/nvim/pack/github/start/copilot.vim

# Move and configure Neovim files
mv ~/.config/nvim/after ~/.config/nvim/.after

nvim --headless -c "so ~/.config/nvim/lua/k-roll/packer.lua" -c 'autocmd User PackerComplete quitall' -c "PackerSync"

mv ~/.config/nvim/.after ~/.config/nvim/after

# Setup Copilot
nvim -c "Copilot setup" -c "q!"

echo "SETUP COMPLETE!!!"
