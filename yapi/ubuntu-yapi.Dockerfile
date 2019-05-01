FROM ubuntu:17.10
MAINTAINER flyceek <flyceek@gmail.com>

ARG NODEJS_VER=8.9.0
ARG NODEJS_FILENAME=node-v${NODEJS_VER}-linux-x64.tar.gz
ARG NODEJS_FILE_EXTRACT_DIR=node-v${NODEJS_VER}-linux-x64
ARG NODEJS_FILEURL=https://npm.taobao.org/mirrors/node/v${NODEJS_VER}/${NODEJS_FILENAME}

ARG YAPI_WORK_HOME=/opt/yapi
ARG YAPI_VER=1.5.14
ARG YAPI_USER=yapi
ARG YAPI_GROUP=yapi
ARG YAPI_FILENAME=v${YAPI_VER}.tar.gz
ARG YAPI_FILE_EXTRACT_DIR=yapi-v${YAPI_VER}
ARG YAPI_FILEURL=https://github.com/YMFE/yapi/archive/${YAPI_FILENAME}

ENV YAPI_SRC_PATH=${YAPI_WORK_HOME}/${YAPI_FILE_EXTRACT_DIR}


RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        build-essential \
        python \
        wget \
        git \
        apt-transport-https \
        ca-certificates \
    && npm config set registry https://registry.npm.taobao.org/ \
    && npm i -g pm2@latest --no-optional \
    && groupadd --gid 1000 ${YAPI_GROUP} \
    && useradd --uid 1000 --gid ${YAPI_GROUP} --shell /bin/bash --create-home ${YAPI_USER} \
    && mkdir -p ${YAPI_SRC_PATH} \
    && cd ${YAPI_WORK_HOME} \
    && wget ${NODEJS_FILEURL} \
    && tar -xzvf ${NODEJS_FILENAME} \
    && rm ${NODEJS_FILENAME} \
    && ln -s ${YAPI_WORK_HOME}/${NODEJS_FILE_EXTRACT_DIR}/bin/node /usr/local/bin/node \
    && ln -s ${YAPI_WORK_HOME}/${NODEJS_FILE_EXTRACT_DIR}/bin/npm /usr/local/bin/npm \
    && wget ${YAPI_FILEURL} \
    && tar -xzvf ${YAPI_FILENAME} -C ${YAPI_FILE_EXTRACT_DIR} --strip-components 1 \
    && rm ${YAPI_FILENAME} \
    && chown -R ${YAPI_USER}:${YAPI_GROUP} ${YAPI_WORK_HOME} \
    && { \
		echo '#!/bin/sh'; \
        echo 'cd ${YAPI_SRC_PATH}'; \
		echo 'npm install --production'; \
        echo 'npm run install-server';\
        #echo 'npm run start'; \
        echo 'pm2 start server/app.js'; \
	} > /usr/local/bin/yapi-initdb-start \
	&& chmod +x /usr/local/bin/yapi-initdb-start \
    && { \
		echo '#!/bin/sh'; \
        echo 'cd ${YAPI_SRC_PATH}'; \
		echo 'npm install --production'; \
        #echo 'npm run start'; \
        echo 'pm2 start server/app.js --watch'; \
	} > /usr/local/bin/yapi-start \
	&& chmod +x /usr/local/bin/yapi-start

USER ${YAPI_USER}
WORKDIR ${YAPI_SRC_PATH}
CMD ["yapi-initdb-start"] 