sudo apt update -y
sudo apt upgrade -y

sudo apt install gh neovim tmux nodejs rsync gcc -y

gh auth login

mkdir -p ~/.config/tmux/plugins/catppuccin

git clone https://github.com/catppuccin/tmux.git\
    ~/.config/tmux/plugins/catppuccin/tmux

git clone https://github.com/tmux-plugins/tmux-battery\
    ~/.config/tmux/plugins/tmux-battery

git clone https://github.com/tmux-plugins/tmux-cpu\
    ~/.config/tmux/plugins/tmux-cpu

git clone https://github.com/ofirgall/tmux-window-name\
    ~/.config/tmux/plugins/tmux-window-name

rsync -a --update --ignore-existing src/ ~/

mv ~/.config/nvim/after ~/.config/nvim/.after

git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

git clone https://github.com/github/copilot.vim.git \
  ~/.config/nvim/pack/github/start/copilot.vim

nvim -c "so ~/.config/nvim/lua/k-roll/packer.lua" -c "PackerSync" -c "q!"

mv ~/.config/nvim/.after ~/.config/nvim/after

nvim -c "Copilot setup" -c "q!"

