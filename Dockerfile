FROM debian:unstable

RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/50pairbox

RUN apt-get update
RUN apt-get -qy upgrade
RUN apt-get -qy install \
        apt-file \
        apt-transport-https \
        aptitude \
        build-essential \
        ca-certificates \
        curl \
        diffstat \
        emacs-nox \
        exuberant-ctags \
        file \
        fonts-dejavu \
        git \
        gnupg \
        htop \
        ipython \
        jq \
        less \
        libcurl4-gnutls-dev \
        libgconf-2-4 \
        libgmp-dev \
        libgtk2.0-0 \
        libnotify4 \
        libnss3 \
        libtinfo-dev \
        libx11-dev \
        libx11-xcb1 \
        libxft-dev \
        libxkbfile1 \
        libxss1 \
        libxtst6 \
        locales \
        man \
        moreutils \
        ncdu \
        openssh-client \
        openssh-server \
        rsync \
        silversearcher-ag \
        sudo \
        tmux \
        tree \
        unzip \
        vim \
        wget \
        xfonts-base \
        zip

RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN echo 'deb https://deb.nodesource.com/node_8.x sid main' > /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get -qy install nodejs

# RUN curl -s https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
# RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/google-chrome.list
# RUN apt-get update && apt-get -qy install google-chrome-stable

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    echo 'fr_FR.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

RUN mkdir /var/run/sshd
RUN chmod 0755 /var/run/sshd
RUN sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

RUN /usr/sbin/useradd --create-home --shell /bin/bash --uid 1000 pairbox

RUN echo "pairbox ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/pairbox \
    && chmod 0440 /etc/sudoers.d/pairbox

# COPY start-xvnc.sh /usr/local/bin/


RUN curl -L -o /tmp/vscode.deb https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable && \
        dpkg -i /tmp/vscode.deb

RUN curl -L -o /tmp/stack.tar.gz https://www.stackage.org/stack/linux-x86_64-static && \
        tar -C /usr/local/bin/ --strip-components=1 --wildcards -xf /tmp/stack.tar.gz stack*/stack

USER pairbox

RUN mkdir -p /home/pairbox/.ssh/ /home/pairbox/.vim/autoload/ /home/pairbox/src/ /home/pairbox/.i3/ /home/pairbox/.vnc/

RUN for user in mebubo; do \
        curl -s https://api.github.com/users/$user/keys | jq -r .[].key >> /home/pairbox/.ssh/authorized_keys;\
     done

# RUN cd /home/pairbox/src/ && git clone https://github.com/mebubo/st
# RUN cd /home/pairbox/src/st && make && sudo make install

# RUN cd /home/pairbox/src/ && git clone https://github.com/mebubo/dotfiles
RUN cd /home/pairbox/ && \
        for f in .vimrc .bashrc .inputrc .tmux.conf .vim/autoload/plug.vim .environment \
                .i3/config .npmrc .vnc/vnc.conf .vnc/Xvnc-session .gitconfig; \
                        do \
                                ln -sf /home/pairbox/src/dotfiles/$f $f; \
                        done

# RUN npm install -g yarn purescript bower pulp
# RUN cargo install ripgrep

USER root

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]
