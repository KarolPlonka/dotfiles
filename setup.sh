#!/bin/bash


# Exit immediately if a command exits with a non-zero status
set -e

# Parse command-line arguments
NO_GITHUB=false
NO_UPDATE=false
SYM_LINK=false
for arg in "$@"
do
    if [ "$arg" == "--no-github" ]; then
        NO_GITHUB=true
    elif [ "$arg" == "--no-update" ]; then
        NO_UPDATE=true
    elif [ "$arg" == "--symlink" ]; then
        SYM_LINK=true
    else
        echo "Invalid argument: $arg"
        exit 1
    fi
done


# Update and upgrade the system
if [ "$NO_UPDATE" = false ]; then
    sudo apt update -y
    sudo apt upgrade -y
fi

# Install necessary packages
sudo apt install gh neovim tmux nodejs gcc xclip ripgrep python3-venv xdg-utils -y

# Install NVM and Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
. "$HOME/.nvm/nvm.sh" && nvm install node

# Authenticate with GitHub CLI if --no-github flag is not set
if [ "$NO_GITHUB" = false ]; then
    echo "Go to https://github.com/login/device/ on already logged device if no browser."
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

# dependencies for tmux-window-name
sudo apt install -y python3-libtmux

git clone https://github.com/ofirgall/tmux-window-name \
    ~/.config/tmux/plugins/tmux-window-name


# Inject into .bashrc
echo "source ~/.config/bash/bash_config.sh" >> ~/.bashrc


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

repo_dir=$(pwd)

# Find all files and directories in TARGET_CONFIG
echo Creating link for config files...
find ".config" | while read -r path; do
    # Determine relative path
    source_path="$repo_dir/$path"
    target_path="$HOME/$path"

    if [ -d "$source_path" ]; then
        mkdir -p "$target_path"
    elif [ -f "$source_path" ]; then
        if [ "$SYM_LINK" = true ]; then
            ln -sv "$source_path" "$target_path"
        else
            ln -sfv "$source_path" "$target_path"
        fi
    fi
done


# Grant execute permission to all scripts
find .config -type f -name "*.sh" -o -name "*.py" | while read -r path; do
    sudo chmod +x "$path"
done



echo "SETUP COMPLETE! run 'exec bash' to load new config"

