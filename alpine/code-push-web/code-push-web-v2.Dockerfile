FROM node:6.17.1-alpine
MAINTAINER flyceek <flyceek@gmail.com>

ENV CODE_PUSH_WEB_HOME=/opt/code-push-web
ARG CODE_PUSH_WEB_VERSION=0.3
ARG CODE_PUSH_WEB_USER=codepushweb
ARG CODE_PUSH_WEB_GROUP=codepushweb
ARG CODE_PUSH_WEB_GITURL=https://github.com/lisong/code-push-web.git

COPY config.js /config.js

RUN apk add --update --no-cache --virtual=.update-dependencies git \
    && addgroup -g 1090 ${CODE_PUSH_WEB_GROUP} \
    && adduser -h /home/${CODE_PUSH_WEB_USER} -u 1090 -G ${CODE_PUSH_WEB_GROUP} -s /bin/bash -D ${CODE_PUSH_WEB_USER} \
    && mkdir -p ${CODE_PUSH_WEB_HOME} \
    && cd ${CODE_PUSH_WEB_HOME} \
    && git clone --depth=1 --single-branch --branch=master ${CODE_PUSH_WEB_GITURL} ${CODE_PUSH_WEB_HOME} \
    && cp /config.js src/config.js \
    && npm install --registry https://registry.npm.taobao.org \
    && npm run build -- --release \
    && cd ./build \
    && npm install --registry https://registry.npm.taobao.org \
    && { \
        echo '#!/bin/sh'; \
        echo 'cd ${CODE_PUSH_WEB_HOME}/build'; \
        echo 'node server.js'; \
    } > /usr/local/bin/code-push-web-start \
    && chmod +x /usr/local/bin/code-push-web-start \
    && chown -R 777 ${CODE_PUSH_WEB_USER}:${CODE_PUSH_WEB_GROUP} ${CODE_PUSH_WEB_HOME} \
    && echo "root:123321" | chpasswd

USER ${CODE_PUSH_WEB_USER}
EXPOSE 3001
WORKDIR ${CODE_PUSH_WEB_HOME}
CMD ["code-push-web-start"]
