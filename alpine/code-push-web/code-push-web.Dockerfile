FROM node:8.16.0-alpine
MAINTAINER flyceek <flyceek@gmail.com>

ENV CODE_PUSH_WEB_HOME=/var/code-push-web-home
ARG CODE_PUSH_WEB_GITURL=https://github.com/lisong/code-push-web.git

RUN apk add --update --no-cache --virtual=.update-dependencies git \
    && mkdir -p ${CODE_PUSH_WEB_HOME} \
    && cd ${CODE_PUSH_WEB_HOME} \
    && git clone --depth=1 --single-branch --branch=master ${CODE_PUSH_WEB_GITURL} code-push-web \
    && { \
		echo '#!/bin/sh'; \
        echo 'cd ${CODE_PUSH_WEB_HOME}/code-push-web' \
		echo 'npm run build'; \
        echo 'cd ./build'; \
        echo 'npm install'; \
        echo 'node ./server.js'; \
	} > /usr/local/bin/code-push-web-start \
    && chmod +x /usr/local/bin/code-push-web-start \
    && echo "root:123321" | chpasswd


WORKDIR ${CODE_PUSH_WEB_HOME}
CMD ["code-push-web-start"] 