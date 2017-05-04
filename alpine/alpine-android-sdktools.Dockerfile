FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ARG WORK_DIR=/opt/soft/android
ARG SDK_TOOLS_VERSION=r25.2.3
ARG SDK_TOOLS_FILE_NAME=tools_${ANDROID_SDK_TOOLS_VERSION}-linux.zip
ARG SDK_TOOLS_FILE_SHA256=1b35bcb94e9a686dff6460c8bca903aa0281c6696001067f34ec00093145b560
ARG SDK_TOOLS_FILE_URL=https://dl.google.com/android/repository/${SDK_TOOLS_FILE_NAME}
ENV ANDROID_HOME=/opt/soft/android-sdk

RUN apk add --no-cache wget bash \
    && mkdir -p ${ANDROID_HOME} \
    && cd ${ANDROID_HOME} \
    && wget --no-cookies --no-check-certificate --directory-prefix=${ANDROID_HOME} ${SDK_TOOLS_FILE_URL} \
    && echo "${SDK_TOOLS_FILE_SHA256}  ${SDK_TOOLS_FILE_NAME}" | sha256sum -c - \
    && unzip ${SDK_TOOLS_FILE_NAME} -d ${ANDROID_HOME} \
    && rm -f ${SDK_TOOLS_FILE_NAME}