FROM debian:unstable

RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/50pairbox

RUN apt-get update
RUN apt-get -qy install tmux vim ipython openssh-server ca-certificates \
        jq curl git sudo openssh-client ghc emacs-nox less moreutils locales aptitude \
        apt-transport-https build-essential htop unzip file wget tree ncdu rsync \
        libgconf-2-4 libnotify4 gnupg libx11-dev libxft-dev \
        xfonts-base vnc4server tightvncserver tigervnc-standalone-server i3 i3status \
        chromium firefox xfce4-terminal rofi suckless-tools fonts-dejavu \
        silversearcher-ag

RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN echo 'deb https://deb.nodesource.com/node_7.x sid main' > /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get -qy install nodejs

RUN echo -e 'en_US.UTF-8 UTF-8\nfr_FR.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

RUN mkdir /var/run/sshd
RUN chmod 0755 /var/run/sshd
RUN sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

RUN /usr/sbin/useradd --create-home --shell /bin/bash --uid 1000 pairbox

RUN echo "pairbox ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/pairbox \
    && chmod 0440 /etc/sudoers.d/pairbox

COPY start-xvnc.sh /usr/local/bin/

RUN curl -o /tmp/code.tar.gz https://vscode-update.azurewebsites.net/latest/linux-x64/stable && dpkg -i /tmp/code.tar.gz

USER pairbox

RUN mkdir -p /home/pairbox/.ssh/ /home/pairbox/.vim/autoload/ /home/pairbox/src/ /home/pairbox/.i3/

RUN for user in mebubo uuzaix; do \
        curl -s https://api.github.com/users/$user/keys | jq -r .[].key >> /home/pairbox/.ssh/authorized_keys;\
     done

RUN cd /home/pairbox/src/ && git clone https://github.com/mebubo/st
RUN cd /home/pairbox/src/st && make && sudo make install

RUN cd /home/pairbox/src/ && git clone https://github.com/mebubo/dotfiles
RUN cd /home/pairbox/ && \
        for f in .vimrc .bashrc .inputrc .tmux.conf .vim/autoload/plug.vim .environment \
                .i3/config .npmrc; \
                        do \
                                ln -sf /home/pairbox/src/dotfiles/$f $f; \
                        done

RUN npm install -g yarn

USER root

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
