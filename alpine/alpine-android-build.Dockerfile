FROM flyceek/alpine-jdk:alpine3.5-jdk8
MAINTAINER flyceek <flyceek@gmail.com>

ARG MAVEN_FILE_SAVE_PATH=/opt/soft/mvn
ARG MAVEN_VERSION=3.5.0
ARG MAVEN_FILE_SHA=878b8b93a8f9685aefba5c21a17b46eb141b1122
ARG MAVEN_FILE_NAME=apache-maven-${MAVEN_VERSION}-bin.tar.gz
ARG MAVEN_FILE_EXTRACT_DIR=apache-maven-${MAVEN_VERSION}
ARG MAVEN_FILE_URL=http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/${MAVEN_FILE_NAME}

ARG GRADLE_FILE_SAVE_HOME=/opt/soft/gradle
ARG GRADLE_WORK_HOME=${WORK_USER_HOME}/.gradle
ARG GRADLE_VERSION=2.14.1
ARG GRADLE_FILE_NAME=gradle-${GRADLE_VERSION}-bin.zip
ARG GRADLE_FILE_EXTRACT_DIR=gradle-${GRADLE_VERSION}
ARG GRADLE_FILE_URL=https://services.gradle.org/distributions/${GRADLE_FILE_NAME}

ENV MAVEN_HOME=${MAVEN_FILE_SAVE_PATH}/${MAVEN_FILE_EXTRACT_DIR}
ENV GRADLE_HOME=${GRADLE_FILE_SAVE_HOME}/${GRADLE_FILE_EXTRACT_DIR}
ENV ANDROID_HOME=/opt/soft/android
ENV PATH=${PATH}:${MAVEN_HOME}/bin:${GRADLE_HOME}/bin

RUN apk update && apk upgrade \
    && apk add --no-cache --virtual=build-dependencies --update unzip wget \
    && apk add --no-cache --virtual=build-dependencies gcc zlib.i686 libstdc++.i686 \
    && mkdir -p ${MAVEN_HOME} \
    && cd ${MAVEN_FILE_SAVE_PATH} \
    && wget --no-check-certificate --no-cookies ${MAVEN_FILE_URL} \
    && echo "${MAVEN_FILE_SHA}  ${MAVEN_FILE_NAME}" | sha1sum -c - \
    && tar -zvxf ${MAVEN_FILE_NAME} -C ${MAVEN_HOME} --strip-components=1 \
    && rm -f ${MAVEN_FILE_NAME} \
    && ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn \
    && mkdir -p ${GRADLE_HOME} \
    && cd ${GRADLE_FILE_SAVE_HOME} \
    && wget --no-check-certificate --no-cookies ${GRADLE_FILE_URL} \
    && unzip ${GRADLE_FILE_NAME} -d ${GRADLE_FILE_SAVE_HOME} \
	&& rm -f ${GRADLE_FILE_NAME} \
    && ln -s ${GRADLE_HOME}/bin/gradle /usr/bin/gradle \
    && mkdir -p ${ANDROID_HOME}

VOLUME ${ANDROID_HOME}
VOLUME ${GRADLE_WORK_HOME}