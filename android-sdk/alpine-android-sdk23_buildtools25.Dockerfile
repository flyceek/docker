FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ENV SDK_TOOLS_VERSION='r25.2.3'
ARG SDK_TOOLS_FILE_NAME=tools_${SDK_TOOLS_VERSION}-linux.zip
ARG SDK_TOOLS_FILE_SHA256=1b35bcb94e9a686dff6460c8bca903aa0281c6696001067f34ec00093145b560
ARG SDK_TOOLS_FILE_URL=https://dl.google.com/android/repository/${SDK_TOOLS_FILE_NAME}

ENV ANDROID_BUILD_TOOLS='build-tools-25.0.0'
ENV ANDROID_SDK='android-23'
ENV ANDROID_EXTRA_SDK='extra-android-support,extra-android-m2repository,extra-google-google_play_services,extra-google-m2repository,extra-google-analytics_sdk_v2'

ENV LANG=C.UTF-8
ENV JAVA_OPENJDK_VERSION=8.131.11-r2
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV ANDROID_HOME=/opt/soft/android-sdk
ENV PATH=$PATH:${JAVA_HOME}/jre/bin:${JAVA_HOME}/bin

RUN { \
        echo '#!/bin/sh'; \
        echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
    && chmod +x /usr/local/bin/docker-java-home \
	&& apk add --no-cache openjdk8="${JAVA_OPENJDK_VERSION}" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ] \ 
    && apk add --no-cache --virtual=.sdk-update-dependencies wget unzip \
    && mkdir -p ${ANDROID_HOME} \
    && cd ${ANDROID_HOME} \
    && wget --no-cookies --no-check-certificate ${SDK_TOOLS_FILE_URL} \
    && echo "${SDK_TOOLS_FILE_SHA256}  ${SDK_TOOLS_FILE_NAME}" | sha256sum -c - \
    && unzip ${SDK_TOOLS_FILE_NAME} \
    && rm -f ${SDK_TOOLS_FILE_NAME} \
    && cd ${ANDROID_HOME}/tools \
    && echo y | ./android update sdk --all --no-ui --force --filter tools,platform-tools,${ANDROID_BUILD_TOOLS},${ANDROID_SDK},${ANDROID_EXTRA_SDK} \
    && cd / \
    && rm -fr ${ANDROID_HOME}/tools \
    && apk update \
    && apk del .sdk-update-dependencies \
    && apk del openjdk8

VOLUME ${ANDROID_HOME}