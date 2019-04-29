FROM node:10.6-alpine
MAINTAINER flyceek <flyceek@gmail.com>

ARG YAPI_WORK_HOME=/opt/yapi
ARG YAPI_USER=yapi
ARG YAPI_GROUP=yapi
ARG YAPI_VER=1.5.14
ARG YAPI_FILE_NAME=v${YAPI_VER}.tar.gz
ARG YAPI_FILE_EXTRACT_DIR=yapi-v${YAPI_VER}
ARG YAPI_FILE_URL=https://github.com/YMFE/yapi/archive/${YAPI_FILE_NAME}

ENV YAPI_SRC_PATH=${YAPI_WORK_HOME}/${YAPI_FILE_EXTRACT_DIR}

RUN apk add --update --no-cache --virtual=.yapi-dependencies \
        git \
        wget \
        gcc \
        python \
        tar \
        xz \
        make \
    && npm config set registry https://registry.npm.taobao.org/ \
    && npm i -g pm2@latest --no-optional \
    && addgroup -g 1090 ${YAPI_GROUP} \
    && adduser -h /home/${YAPI_USER} -u 1090 -G ${YAPI_GROUP} -s /bin/bash -D ${YAPI_USER} \
    && mkdir -p ${YAPI_SRC_PATH} \
    && cd ${YAPI_WORK_HOME} \
    && wget ${YAPI_FILE_URL} \
    && tar -xzvf ${YAPI_FILE_NAME} -C ${YAPI_FILE_EXTRACT_DIR} --strip-components 1 \
    && rm ${YAPI_FILE_NAME} \
    && cd ${YAPI_SRC_PATH} \
    && npm install --production \
    && { \
		echo '#!/bin/sh'; \
        echo 'cd ${YAPI_SRC_PATH}'; \
        echo 'npm run install-server'; \
        echo 'pm2 start server/app.js'; \
        echo 'pm2 logs'; \
	} > /usr/local/bin/yapi-initdb-start \
	&& chmod +x /usr/local/bin/yapi-initdb-start \
    && { \
		echo '#!/bin/sh'; \
        echo 'cd ${YAPI_SRC_PATH}'; \
        echo 'pm2 start server/app.js'; \
        echo 'pm2 logs'; \
	} > /usr/local/bin/yapi-start \
	&& chmod +x /usr/local/bin/yapi-start \
    && chown -R ${YAPI_USER}:${YAPI_GROUP} ${YAPI_WORK_HOME} \
    && echo "root:123321" | chpasswd

USER ${YAPI_USER}
EXPOSE 3000
WORKDIR ${YAPI_SRC_PATH}
CMD ["yapi-initdb-start"] 