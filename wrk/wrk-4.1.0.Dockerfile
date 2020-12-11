FROM alpine:latest
MAINTAINER flyceek@gmail.com

ARG WRK_VERSION=4.1.0
ARG WRK_FILE_NAME=${WRK_VERSION}.tar.gz
ARG WRK_FILE_SRC_DIR=wrk-${WRK_VERSION}
ARG WRK_FILE_URL=https://github.com/wg/wrk/archive/${WRK_FILE_NAME}

RUN apk add --update alpine-sdk perl wget unzip libgcc linux-headers \
    && mkdir -p /tmp/wrk/${WRK_FILE_SRC_DIR} \
    && cd /tmp/wrk \
    && wget -O ${WRK_FILE_NAME} ${WRK_FILE_URL} \
    && tar -xvf ${WRK_FILE_NAME} -C /tmp/wrk/${WRK_FILE_SRC_DIR} --strip-components=1 \
    && cd /tmp/wrk/${WRK_FILE_SRC_DIR} \
    && make \
    && mv ./wrk /usr/local/bin \
    && rm -rf /tmp/wrk \
    && apk del --purge alpine-sdk perl

WORKDIR /data
ENTRYPOINT ["wrk"]