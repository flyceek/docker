FROM node:10.6-alpine
MAINTAINER flyceek <flyceek@gmail.com>

ARG WORK_DIR=/opt/soft/yapi
ARG YAPI_USER=yapi
ARG YAPI_GROUP=yapi
ARG YAPI_VER=1.5.14
ARG YAPI_FILENAME=v${YAPI_VER}.tar.gz
ARG YAPI_FILE_EXTRACT_DIR=yapi-v${YAPI_VER}
ARG YAPI_FILEURL=https://github.com/YMFE/yapi/archive/${YAPI_FILENAME}

RUN apk add --update --no-cache --virtual=.yapi-dependencies \
        git \
        wget \
        python \
        tar \
        xz \
        make \
    && mkdir -p ${WORK_DIR} \
    && cd ${WORK_DIR} \
    && addgroup -g 1090 ${YAPI_GROUP} \
    && adduser -h /home/${YAPI_USER} -u 1090 -G ${YAPI_GROUP} -s /bin/bash -D ${YAPI_USER} \
    && mkdir -p ${YAPI_FILE_EXTRACT_DIR} \
    && wget ${YAPI_FILEURL} \
    && tar -xzvf ${YAPI_FILENAME} -C ${YAPI_FILE_EXTRACT_DIR} --strip-components 1 \
    && rm ${YAPI_FILENAME} \
    && chown -R ${YAPI_USER}:${YAPI_GROUP} ${WORK_DIR} \
    && { \
		echo '#!/bin/sh'; \
		echo 'npm install'; \
        echo 'npm run install-server';\
        echo 'npm run start'; \
	} > /usr/local/bin/yapi-initdb-start \
	&& chmod +x /usr/local/bin/yapi-initdb-start \
    && { \
		echo '#!/bin/sh'; \
		echo 'npm install'; \
        echo 'npm run start'; \
	} > /usr/local/bin/yapi-start \
	&& chmod +x /usr/local/bin/yapi-start \
    && echo "root:123321" | chpasswd

USER ${YAPI_USER}
WORKDIR ${WORK_DIR}/${YAPI_FILE_EXTRACT_DIR}
CMD ["yapi-initdb-start"] 