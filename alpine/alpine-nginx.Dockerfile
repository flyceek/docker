FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ARG NGINX_VERSION=1.9.9
ARG NGINX_FILE_NAME=nginx-${NGINX_VERSION}.tar.gz
ARG NGINX_FILE_EXTRACT_DIR=nginx-${NGINX_VERSION}
ARG NGINX_FILE_URL=http://nginx.org/download/${NGINX_FILE_NAME}
ARG WORK_DIR=/tmp

RUN apk --update add --no-cache --virtual .run-deps \
        ca-certificates \
        openssl \
        pcre \
        zlib \
    && apk --update add --no-cache --virtual .build-deps \
		build-base \
		libc-dev \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		wget \
    && addgroup -S nginx \
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && CONFIG=" \
        --prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --user=nginx \
		--group=nginx \
    " \
    && mkdir -p ${WORK_DIR} \
    && cd ${WORK_DIR} \
    && wget ${NGINX_FILE_URL} \
    && tar -zxvf ${NGINX_FILE_NAME} \
    && cd ${NGINX_FILE_EXTRACT_DIR} \
    && ./configure $CONFIG --with-debug \
    && make \
    && make install \
    && make clean \
    && strip -s /usr/sbin/nginx \
    && cd / \
    && apk del .build-deps \
    && rm -rf ${WORK_DIR}/* \
    && rm -rf /var/cache/apk/* \
    && rm -rf /var/www/* \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx"]
EXPOSE 80
WORKDIR /etc/nginx
CMD ["nginx", "-g", "daemon off;"]