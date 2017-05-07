FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ARG NGINX_VERSION=1.9.9
ARG NGINX_FILE_NAME=nginx-${NGINX_VERSION}.tar.gz
ARG NGINX_FILE_EXTRACT_DIR=nginx-${NGINX_VERSION}
ARG NGINX_FILE_URL=http://nginx.org/download/${NGINX_FILE_NAME}

ARG NGINX_HOME=/opt/soft/nginx
ARG NGINX_USER=nginx
ARG NGINX_USER_UID=10069
ARG NGINX_GROUP=nginx
ARG NGINX_GID=10069
ARG WORK_DIR=/tmp
ENV PATH=${PATH}:${NGINX_HOME}/bin 

RUN apk --update add --no-cache --virtual .run-dependencies \
        pcre \
        zlib \
    && apk --update add --no-cache --virtual .build-dependencies \
        gcc \
		make \
		libc-dev \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		wget \
    && CONFIG="\
        --prefix=${NGINX_HOME} \
        --sbin-path=${NGINX_HOME}/bin/nginx \
		--error-log-path=${NGINX_HOME}/log/error.log \
		--http-log-path=${NGINX_HOME}/log/access.log \
		--pid-path=${NGINX_HOME}/run/nginx.pid \
        --lock-path=${NGINX_HOME}/run/nginx.lock\
		--with-http_ssl_module \
        --with-http_gzip_static_module \
        --user=${NGINX_USER} \
		--group=${NGINX_GROUP} \
    " \
    && mkdir -p ${WORK_DIR} \
    && mkdir -p ${NGINX_HOME}/www ${NGINX_HOME}/sites ${NGINX_HOME}/certs \
    && addgroup -g ${NGINX_GID} ${NGINX_GROUP} \
    && adduser -D -h ${NGINX_HOME} -G ${NGINX_GROUP} -s /sbin/nologin -u ${NGINX_USER_UID} ${NGINX_USER} \
    && cd ${WORK_DIR} \
    && wget ${NGINX_FILE_URL} \
    && tar -zxvf ${NGINX_FILE_NAME} \
    && cd ${NGINX_FILE_EXTRACT_DIR} \
    && ./configure ${CONFIG} \
    && make -j2 \
    && make install \
    && make clean \
    && strip -s ${NGINX_HOME}/bin/nginx \
    && ln -sf /dev/stdout ${NGINX_HOME}/log/access.log \
    && ln -sf /dev/stderr ${NGINX_HOME}/log/error.log \
    && cd / \
    && apk del .build-dependencies \
    && rm -rf ${WORK_DIR}/* \
    && rm -rf /var/cache/apk/* \
    && rm -rf /var/www/* 

EXPOSE 80
WORKDIR ${NGINX_HOME}
CMD ["nginx", "-g", "daemon off;"]