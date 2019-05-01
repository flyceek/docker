FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ENV SDK_TOOLS_VERSION='4333796'
ARG SDK_TOOLS_FILE_NAME=sdk-tools-linux-${SDK_TOOLS_VERSION}.zip
ARG SDK_TOOLS_FILE_SHA1=8c7c28554a32318461802c1291d76fccfafde054
ARG SDK_TOOLS_FILE_URL=https://dl.google.com/android/repository/${SDK_TOOLS_FILE_NAME}

ENV ANDROID_BUILD_TOOLS='build-tools-27.0.1'
ENV ANDROID_SDK='android-27'
ENV ANDROID_EXTRA_SDK='extra-android-support,extra-android-m2repository,extra-google-google_play_services,extra-google-m2repository,extra-google-analytics_sdk_v2'

ARG JAVA_VERSION=8u151
ARG JAVA_OPENJDK_VERSION=8.151.12-r0
ENV LANG=C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV ANDROID_HOME=/opt/soft/android-sdk
ENV PATH=$PATH:${JAVA_HOME}/jre/bin:${JAVA_HOME}/bin

ARG ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download"
ARG ALPINE_GLIBC_PACKAGE_VERSION="2.6-r0"
ARG ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-${ALPINE_GLIBC_PACKAGE_VERSION}.apk"
ARG ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-${ALPINE_GLIBC_PACKAGE_VERSION}.apk"
ARG ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-${ALPINE_GLIBC_PACKAGE_VERSION}.apk" 

RUN { \
        echo '#!/bin/sh'; \
        echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
    && chmod +x /usr/local/bin/docker-java-home \
	&& apk add --no-cache openjdk8="${JAVA_OPENJDK_VERSION}" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ] \
    && apk add --no-cache libstdc++ \
    && apk add --no-cache --virtual=.sdk-update-dependencies wget unzip ca-certificates\
    && mkdir -p ${ANDROID_HOME} \
    && cd ${ANDROID_HOME} \
    && wget "https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/sgerrand.rsa.pub" -O "/etc/apk/keys/sgerrand.rsa.pub" \
    && wget \
        "${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_PACKAGE_VERSION}/${ALPINE_GLIBC_BASE_PACKAGE_FILENAME}" \
        "${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_PACKAGE_VERSION}/${ALPINE_GLIBC_BIN_PACKAGE_FILENAME}" \
        "${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_PACKAGE_VERSION}/${ALPINE_GLIBC_I18N_PACKAGE_FILENAME}" \
    && apk add --no-cache \
        "${ALPINE_GLIBC_BASE_PACKAGE_FILENAME}" \
        "${ALPINE_GLIBC_BIN_PACKAGE_FILENAME}" \
        "${ALPINE_GLIBC_I18N_PACKAGE_FILENAME}" \
    && rm "/etc/apk/keys/sgerrand.rsa.pub" \
    && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true \
    && echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh
    && wget --no-cookies --no-check-certificate ${SDK_TOOLS_FILE_URL} \
    && echo "${SDK_TOOLS_FILE_SHA1}  ${SDK_TOOLS_FILE_NAME}" | sha1sum -c - \
    && unzip ${SDK_TOOLS_FILE_NAME} \
    && rm -f ${SDK_TOOLS_FILE_NAME} \
    && cd ${ANDROID_HOME}/tools \
    && echo y | ./android update sdk --all --no-ui --force --filter tools,platform-tools,${ANDROID_BUILD_TOOLS},${ANDROID_SDK},${ANDROID_EXTRA_SDK} \
    && cd / \
    && rm -fr ${ANDROID_HOME}/tools \
    && apk update \
    && apk del .sdk-update-dependencies \
    && apk del glibc-i18n \
    && apk del openjdk8

VOLUME ${ANDROID_HOME}