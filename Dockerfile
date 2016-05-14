FROM ubuntu:latest

RUN apt-get update
RUN apt-get -qy --no-install-recommends install tmux vim ipython openssh-server \
        jq curl git nodejs npm sudo openssh-client ghc emacs-nox

RUN mkdir /var/run/sshd
RUN chmod 0755 /var/run/sshd
RUN sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

RUN /usr/sbin/useradd --create-home --shell /bin/bash --uid 1000 pairbox

RUN echo "pairbox ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/pairbox \
    && chmod 0440 /etc/sudoers.d/pairbox

USER pairbox

RUN mkdir -p /home/pairbox/.ssh/ /home/pairbox/.vim/autoload/ /home/pairbox/src/

RUN for user in mebubo uuzaix; do \
        curl -s https://api.github.com/users/$user/keys | jq -r .[].key >> /home/pairbox/.ssh/authorized_keys;\
     done

RUN cd /home/pairbox/src/ && git clone https://github.com/mebubo/dotfiles
RUN cd /home/pairbox/ && for f in .vimrc .bashrc .inputrc .tmux.conf .vim/autoload/plug.vim; do \
                             ln -sf /home/pairbox/src/dotfiles/$f $f; \
                         done

USER root

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
