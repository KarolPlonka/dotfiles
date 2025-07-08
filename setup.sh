#!/bin/bash


# Exit immediately if a command exits with a non-zero status
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"

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
sudo chmod +x install_deps.sh
bash install_deps.sh

# Install NVM and Node.js
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
fi

# Load nvm and check if node exists
. "$HOME/.nvm/nvm.sh"
if ! command -v node &> /dev/null; then
    echo "Installing node..."
    nvm install node
fi

# Authenticate with GitHub CLI if --no-github flag is not set
if [ "$NO_GITHUB" = false ]; then
    echo "Go to https://github.com/login/device/ on already logged device if no browser."
    gh auth login
    gh extension install github/gh-copilot
fi

# Create directories and clone repositories
mkdir -p ~/.config/tmux/plugins/catppuccin

git clone https://github.com/catppuccin/tmux.git \
    ~/.config/tmux/plugins/catppuccin/tmux

git clone https://github.com/tmux-plugins/tmux-battery \
    ~/.config/tmux/plugins/tmux-battery

git clone https://github.com/tmux-plugins/tmux-cpu \
    ~/.config/tmux/plugins/tmux-cpu

git clone https://github.com/tmux-plugins/tmux-resurrect \
    ~/.config/tmux/plugins/tmux-resurrect

git clone https://github.com/tmux-plugins/tmux-continuum \
    ~/.config/tmux/plugins/tmux-continuum

# dependencies for tmux-window-name
sudo apt install -y python3-libtmux

git clone https://github.com/ofirgall/tmux-window-name \
    ~/.config/tmux/plugins/tmux-window-name

# Install neovim if not already installed
if ! command -v nvim &> /dev/null; then
    echo "Installing Neovim..."

    # try to install Neovim using snap if not built from source
    if command -v snap &> /dev/null; then
        sudo snap install nvim --classic
    else
        # If snap is not available, try to build from source
        echo "Snap not found, building Neovim from source..."
        git clone https://github.com/neovim/neovim /usr/local/src/neovim
        cd /usr/local/src/neovim
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
        cd "$SCRIPT_DIR"
    fi
fi



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


if [ "$SYM_LINK" = true ]; then
    bash link.sh --symlink
else
    bash link.sh
fi


# Inject into .bashrc
echo "source ~/.config/bash/bash_config.sh" >> ~/.bashrc

# Grant execute permission to all scripts
find .config -type f -name "*.sh" -o -name "*.py" | while read -r path; do
    sudo chmod +x "$path"
done

echo "SETUP COMPLETE! run 'exec bash' to load new config"
