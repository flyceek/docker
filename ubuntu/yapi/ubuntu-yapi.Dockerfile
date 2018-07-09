FROM ubuntu:17.10
MAINTAINER flyceek <flyceek@gmail.com>

ARG WORK_DIR=/opt/soft/yapi
ARG NODEJS_VER=8.9.0
ARG NODEJS_FILENAME=node-v${NODEJS_VER}-linux-x64.tar.gz
ARG NODEJS_FILE_EXTRACT_DIR=node-v${NODEJS_VER}-linux-x64
ARG NODEJS_FILEURL=https://npm.taobao.org/mirrors/node/v${NODEJS_VER}/${NODEJS_FILENAME}

ARG YAPI_USER=yapi
ARG YAPI_GROUP=yapi
ARG YAPI_VER=1.3.17
ARG YAPI_FILENAME=v${YAPI_VER}.tar.gz
ARG YAPI_FILE_EXTRACT_DIR=yapi-v${YAPI_VER}
ARG YAPI_FILEURL=https://github.com/YMFE/yapi/archive/${YAPI_FILENAME}

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        build-essential \
        python \
        wget \
        git \
        apt-transport-https \
        ca-certificates \
        # vim \
        # sudo \
        # iputils-ping \
    && mkdir -p ${WORK_DIR} \
    && cd ${WORK_DIR} \
    && groupadd --gid 1000 ${YAPI_GROUP} \
    && useradd --uid 1000 --gid ${YAPI_GROUP} --shell /bin/bash --create-home ${YAPI_USER} \
    && wget ${NODEJS_FILEURL} \
    && tar -xzvf ${NODEJS_FILENAME} \
    && rm ${NODEJS_FILENAME} \
    && ln -s ${WORK_DIR}/${NODEJS_FILE_EXTRACT_DIR}/bin/node /usr/local/bin/node \
    && ln -s ${WORK_DIR}/${NODEJS_FILE_EXTRACT_DIR}/bin/npm /usr/local/bin/npm \
    && mkdir -p ${YAPI_FILE_EXTRACT_DIR} \
    && mkdir -p ${WORK_DIR}/${YAPI_FILE_EXTRACT_DIR}/log \
    && wget ${YAPI_FILEURL} \
    && tar -xzvf ${YAPI_FILENAME} -C ${YAPI_FILE_EXTRACT_DIR} --strip-components 1 \
    && rm ${YAPI_FILENAME} \
    && chown -R ${YAPI_USER}:${YAPI_GROUP} ${WORK_DIR} \
    && { \
		echo '#!/bin/sh'; \
		echo 'npm install'; \
        echo 'npm run install-server';\
        echo 'npm run start'; \
	} > /usr/local/bin/yapi-start \
	&& chmod +x /usr/local/bin/yapi-start

USER ${YAPI_USER}
WORKDIR ${WORK_DIR}/${YAPI_FILE_EXTRACT_DIR}
CMD ["yapi-start"] 