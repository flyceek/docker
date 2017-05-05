FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ARG WORK_DIR=/tmp
ARG SDK_TOOLS_VERSION=r25.2.3
ARG SDK_TOOLS_FILE_NAME=tools_${SDK_TOOLS_VERSION}-linux.zip
ARG SDK_TOOLS_FILE_SHA256=1b35bcb94e9a686dff6460c8bca903aa0281c6696001067f34ec00093145b560
ARG SDK_TOOLS_FILE_URL=https://dl.google.com/android/repository/${SDK_TOOLS_FILE_NAME}

ARG GLIBC_VERSION=2.25-r0
ARG GLIBC_FILE_NAME=glibc-${GLIBC_VERSION}.apk
ARG GLIBC_FILE_URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${GLIBC_FILE_NAME}
ARG GLIBC_BIN_FILE_NAME=glibc-bin-${GLIBC_VERSION}.apk
ARG GLIBC_BIN_FILE_URL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/${GLIBC_BIN_FILE_NAME}
ARG WORK_DIR=/tmp

ENV ANDROID_HOME=/opt/soft/android-sdk

RUN apk add --no-cache --virtual=.build-dependencies libstdc++ wget unzip ca-certificates bash \
    && mkdir -p ${WORK_DIR} \ 
    && mkdir -p ${ANDROID_HOME} \
    && cd ${WORK_DIR} \
    && wget --no-cookies --no-check-certificate ${GLIBC_FILE_URL} \
    && wget --no-cookies --no-check-certificate ${GLIBC_BIN_FILE_URL} \
    && apk add --no-cache --allow-untrusted ${GLIBC_FILE_NAME} \
    && apk add --no-cache --allow-untrusted ${GLIBC_BIN_FILE_NAME} \
    && cd ${ANDROID_HOME} \
    && wget --no-cookies --no-check-certificate ${SDK_TOOLS_FILE_URL} \
    && echo "${SDK_TOOLS_FILE_SHA256}  ${SDK_TOOLS_FILE_NAME}" | sha256sum -c - \
    && unzip ${SDK_TOOLS_FILE_NAME} -d ${ANDROID_HOME} \
    && rm -f ${SDK_TOOLS_FILE_NAME} \
    && cd / \
    && rm -fr ${WORK_DIR}/* \
    && echo "root:123321" | chpasswd