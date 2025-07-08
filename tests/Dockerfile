FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Update and install basic tools, including curl and certificates
COPY install_deps.sh /tmp/install_deps.sh
RUN chmod +x /tmp/install_deps.sh && \
    /tmp/install_deps.sh && \
    rm -rf /tmp/install_deps.sh

RUN git clone https://github.com/neovim/neovim
RUN cd neovim && \ 
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install

# Create a user
RUN useradd -m -s /bin/bash dotfiler && \
    usermod -aG sudo dotfiler && \
    echo 'dotfiler:root' | chpasswd

USER dotfiler

WORKDIR /home/dotfiler

ENV NVM_DIR=/home/dotfiler/.nvm

RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh -k | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install --lts \
    && nvm use default


# Setup workspace
RUN mkdir dotfiles
WORKDIR /home/dotfiler/dotfiles

CMD ["/bin/bash"]

