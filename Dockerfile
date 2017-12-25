FROM debian:unstable

RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/50pairbox

RUN apt-get update \
    && apt-get -qy upgrade \
    && apt-get -qy install \
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
        freeglut3-dev \
        git \
        gnupg \
        gradle \
        htop \
        ipython \
        jq \
        less \
        libcurl4-gnutls-dev \
        libgconf-2-4 \
        libiw-dev \
        libgl1-mesa-dri \
        libgl1-mesa-glx \
        libgl-dev \
        libgmp-dev \
        libgtk2.0-0 \
        libnotify4 \
        libnss3 \
        libsdl2-2.0-0 \
        libsdl2-dev \
        libsecret-1-0 \
        libtinfo-dev \
        libx11-dev \
        libx11-xcb1 \
        libxrandr-dev \
        libxft-dev \
        libxkbfile1 \
        libxss1 \
        libxtst6 \
        locales \
        man \
        mesa-utils \
        moreutils \
        ncdu \
        neovim \
        openssh-client \
        openssh-server \
        rsync \
        sbt \
        silversearcher-ag \
        sqlite3 \
        sudo \
        tmux \
        tree \
        unzip \
        vim \
        wget \
        xauth \
        xfonts-base \
        youtube-dl \
        z3 \
        zip

RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN echo 'deb https://deb.nodesource.com/node_8.x sid main' > /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get -qy install nodejs

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    echo 'fr_FR.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

RUN mkdir /var/run/sshd
RUN chmod 0755 /var/run/sshd
RUN sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

RUN /usr/sbin/groupadd --gid 91 dri
RUN /usr/sbin/useradd --create-home --shell /bin/bash --uid 1000 pairbox --groups 91

RUN echo "pairbox ALL=(ALL) ALL" > /etc/sudoers.d/pairbox \
    && chmod 0440 /etc/sudoers.d/pairbox

RUN curl -L -o /tmp/vscode.deb https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable && \
        dpkg -i /tmp/vscode.deb

RUN curl -L -o /tmp/stack.tar.gz https://www.stackage.org/stack/linux-x86_64-static && \
        tar -C /usr/local/bin/ --strip-components=1 --wildcards -xf /tmp/stack.tar.gz stack*/stack

USER pairbox

RUN mkdir -p /home/pairbox/.ssh/ /home/pairbox/.vim/autoload/ /home/pairbox/src/

COPY --chown=pairbox:pairbox authorized_keys /home/pairbox/.ssh/authorized_keys

RUN cd /home/pairbox/ && \
        for f in .vimrc .bashrc .inputrc .tmux.conf .vim/autoload/plug.vim .environment \
                 .npmrc .gitconfig; \
                        do \
                                ln -sf /home/pairbox/src/dotfiles/$f $f; \
                        done

USER root

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]
