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

RUN wget -O /tmp/JetBrainsMono.zip "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip" && \
    unzip /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono && \
    mkdir -p /usr/share/fonts/truetype/jetbrains && \
    cp /tmp/JetBrainsMono/fonts/ttf/*.ttf /usr/share/fonts/truetype/jetbrains/ && \
    fc-cache -f -v && \
    rm -rf /tmp/JetBrainsMono.zip /tmp/JetBrainsMono

# Setup workspace
RUN mkdir dotfiles
WORKDIR /home/dotfiler/dotfiles

CMD ["/bin/bash"]

