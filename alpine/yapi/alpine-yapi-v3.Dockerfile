FROM node:10.6-alpine
MAINTAINER flyceek <flyceek@gmail.com>

ARG YAPI_WORK_DIR=/opt/soft/yapi
ARG YAPI_USER=yapi
ARG YAPI_GROUP=yapi
ARG YAPI_VER=1.5.14
ARG YAPI_SRC_DIR=yapi-v${YAPI_VER}
ARG YAPI_GIT_URL=https://github.com/YMFE/yapi.git

ENV YAPI_FILE_SRC_PATH=${YAPI_WORK_DIR}/${YAPI_SRC_DIR}

RUN apk add --update --no-cache --virtual=.yapi-dependencies \
        git \
        wget \
        python \
        tar \
        xz \
        make \
    && mkdir -p ${YAPI_WORK_DIR} \
    && cd ${YAPI_WORK_DIR} \
    && addgroup -g 1090 ${YAPI_GROUP} \
    && adduser -h /home/${YAPI_USER} -u 1090 -G ${YAPI_GROUP} -s /bin/bash -D ${YAPI_USER} \
    && git clone --depth=1 --single-branch --branch=master ${YAPI_GIT_URL} ${YAPI_SRC_DIR} \
    && rm ${YAPI_SRC_DIR} \
    && npm install --production --registry https://registry.npm.taobao.org \
    && { \
		echo '#!/bin/sh'; \
        echo 'cd ${YAPI_FILE_SRC_PATH}'; \
        echo 'npm run install-server';\
        echo 'node server/app.js'; \
	} > /usr/local/bin/yapi-initdb-start \
	&& chmod +x /usr/local/bin/yapi-initdb-start \
    && { \
		echo '#!/bin/sh'; \
        echo 'cd ${YAPI_FILE_SRC_PATH}'; \
        echo 'node server/app.js'; \
	} > /usr/local/bin/yapi-start \
	&& chmod +x /usr/local/bin/yapi-start \
    && chown -R ${YAPI_USER}:${YAPI_GROUP} ${YAPI_WORK_DIR} \
    && echo "root:123321" | chpasswd

USER ${YAPI_USER}
EXPOSE 3000
WORKDIR ${YAPI_FILE_SRC_PATH}
CMD ["yapi-initdb-start"] 