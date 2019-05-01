FROM alpine:latest
MAINTAINER flyceek "flyceek@gmail.com"

ARG GOPROXY_WORKDIR=/opt/soft/goproxy
ARG GOPROXY_VERSION=6.9
ARG GOPROXY_FILE_NAME=proxy-linux-amd64.tar.gz
ARG GOPROXY_FILE_EXTRACT_DIR=${GOPROXY_WORKDIR}/proxy-linux-amd64
ARG GOPROXY_FILE_URL=https://github.com/snail007/goproxy/releases/download/v${GOPROXY_VERSION}/${GOPROXY_FILE_NAME}

RUN apk update \
    && apk upgrade \
    && apk add --no-cache wget tar \
    && mkdir -p ${GOPROXY_FILE_EXTRACT_DIR} \
    && cd ${GOPROXY_WORKDIR} \
    && wget -O ${GOPROXY_FILE_NAME} ${GOPROXY_FILE_URL} \
    && tar -xzf ${GOPROXY_FILE_NAME} -C ${GOPROXY_FILE_EXTRACT_DIR} \
    && rm ${GOPROXY_FILE_NAME} \
    && chmod -R 0777 ${GOPROXY_FILE_EXTRACT_DIR} \
    && echo "root:123321" | chpasswd

WORKDIR ${GOPROXY_FILE_EXTRACT_DIR}
# ENTRYPOINT ["./proxy"]