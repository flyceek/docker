FROM node:8.11.4-alpine
MAINTAINER flyceek <flyceek@gmail.com>

COPY ./process.json /process.json

ENV CODE_PUSH_SERVER_HOME=/opt/code-push-server
ARG CODE_PUSH_SERVER_VERSION=0.5.4
ARG CODE_PUSH_SERVER_GITURL=https://github.com/lisong/code-push-server.git

RUN apk add --update --no-cache --virtual=.update-dependencies git \
    && npm config set registry https://registry.npm.taobao.org/ \
    && npm i -g pm2@latest --no-optional \
    && mkdir -p ${CODE_PUSH_SERVER_HOME} \
    && cd ${CODE_PUSH_SERVER_HOME} \
    && git clone --depth=1 --single-branch --branch=master ${CODE_PUSH_SERVER_GITURL} ${CODE_PUSH_SERVER_HOME} \
    && npm install \
    && echo "root:123321" | chpasswd

EXPOSE 3000
WORKDIR ${CODE_PUSH_SERVER_HOME}
CMD ["pm2-docker", "start", "/process.json"]