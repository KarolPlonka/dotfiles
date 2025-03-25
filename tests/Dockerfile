# Use the official Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y \
    sudo \
    curl \
    wget \
    vim \
    git \
    gh \
    neovim \
    tmux \
    nodejs \
    gcc \
    xclip \
    ripgrep \
    python3-venv \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*


# Create a new user named 'dotfiler' with a home directory
RUN useradd -m -s /bin/bash dotfiler

# Add 'dotfiler' to the sudo group (optional)
RUN usermod -aG sudo dotfiler

# Set a password for 'dotfiler' (optional)
RUN echo 'dotfiler:root' | chpasswd

# Switch to the 'dotfiler' user
USER dotfiler

# Set the working directory to the home directory of 'dotfiler'
WORKDIR /home/dotfiler

# Set up any additional environment variables or configurations
ENV HOME /home/dotfiler

# Install nvm and update node
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash  
ENV NVM_DIR=$HOME/.nvm
RUN . "$HOME/.nvm/nvm.sh" && nvm install node




RUN mkdir dotfiles

WORKDIR /home/dotfiler/dotfiles

CMD ["/bin/bash"]
