#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Parse command-line arguments
NO_GITHUB=false
NO_UPDATE=false
for arg in "$@"
do
    if [ "$arg" == "--no-github" ]; then
        NO_GITHUB=true
    elif [ "$arg" == "--no-update" ]; then
        NO_UPDATE=true
    fi
done

# Update and upgrade the system
if [ "$NO_UPDATE" = false ]; then
    sudo apt update -y
    sudo apt upgrade -y
fi

# Install necessary packages
sudo apt install gh neovim tmux nodejs rsync gcc xclip ripgrep python3-venv -y

# Authenticate with GitHub CLI if --no-github flag is not set
if [ "$NO_GITHUB" = false ]; then
    gh auth login
fi

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
# rsync -a --update . ~/


# Install packer.nvim
mkdir -p ~/.local/share/nvim/site/pack/packer/start

git clone --depth 1 https://github.com/wbthomason/packer.nvim \
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# Install Copilot.vim if --no-github flag is not set
if [ "$NO_GITHUB" = false ]; then
    mkdir -p ~/.config/nvim/pack/github/start
    git clone https://github.com/github/copilot.vim.git \
      ~/.config/nvim/pack/github/start/copilot.vim
fi

# Move and configure Neovim files
# mv ~/.config/nvim/after ~/.config/nvim/.after

mkdir -p ~/.config/nvim/lua/k-roll
cp .config/nvim/lua/k-roll/packer.lua ~/.config/nvim/lua/k-roll/packer.lua
nvim --headless -c "so ~/.config/nvim/lua/k-roll/packer.lua" -c 'autocmd User PackerComplete quitall' -c "PackerSync"
rm ~/.config/nvim/lua/k-roll/packer.lua


# mv ~/.config/nvim/.after ~/.config/nvim/after

# Setup Copilot if --no-github flag is not set
if [ "$NO_GITHUB" = false ]; then
    nvim -c "Copilot setup" -c "q!"
fi


rm -rf .git
cd ~
git init
git branch -M linux
git remote add origin https://github.com/KarolPlonka/dotfiles.git
git fetch origin linux

while IFS= read -r line
do
    # echo "rm -f $HOME/$line"
    rm -f $HOME/$line
done < <(git ls-tree -r origin/linux --name-only)

git pull --set-upstream origin linux

echo "SETUP COMPLETE"
echo "You can remove the dotfiles directory now"
