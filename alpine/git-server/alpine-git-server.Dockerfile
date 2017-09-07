FROM flyceek/alpine-ssh:latest
MAINTAINER flyceek <flyceek@gmail.com>

WORKDIR /opt/git-server/

RUN apk add --update --no-cache --virtual=.update-dependencies git \
    && adduser -D -s /usr/bin/git-shell git \
    && echo git:123456 | chpasswd \
    && mkdir -p /home/git/.ssh