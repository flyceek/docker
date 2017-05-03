FROM flyceek/centos7-jdk:latest
MAINTAINER flyceek <flyceek@gmail.com>

RUN yum update -y \
    && yum install -y unzip lsof wget git \
    && yum install -y gcc glibc.i686 zlib.i686 libstdc++.i686 \
    && yum clean all

ARG WORK_USER_NAME="root"
ARG WORK_USER_HOME="/root"

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

ENV MAVEN_HOME=${MAVEN_FILE_SAVE_PATH}/${MAVEN_FILE_EXTRACT_DIR} \
    GRADLE_HOME=${GRADLE_FILE_SAVE_HOME}/${GRADLE_FILE_EXTRACT_DIR} \
    ANDROID_HOME=/opt/soft/android \
    PATH=${PATH}:${MAVEN_HOME}/bin:${GRADLE_HOME}/bin

RUN echo "install maven." \
    && mkdir -p ${MAVEN_FILE_SAVE_PATH} \
    && wget --no-check-certificate --no-cookies --directory-prefix=${MAVEN_FILE_SAVE_PATH} ${MAVEN_FILE_URL} \
    && echo "${MAVEN_FILE_SHA} ${MAVEN_FILE_SAVE_PATH}/${MAVEN_FILE_NAME}" | sha1sum -c - \
    && mkdir -p ${MAVEN_FILE_SAVE_PATH}/${MAVEN_FILE_EXTRACT_DIR} \
    && mkdir -p ${MAVEN_HOME} \
    && tar -zvxf ${MAVEN_FILE_SAVE_PATH}/${MAVEN_FILE_NAME} -C ${MAVEN_HOME} --strip-components=1 \
    && rm -f ${MAVEN_FILE_SAVE_PATH}/${MAVEN_FILE_NAME} \
    && alternatives --install /usr/bin/mvn mvn ${MAVEN_HOME}/bin/mvn 1 \
    && echo "install gradle." \
    && mkdir -p ${GRADLE_FILE_SAVE_HOME} \
    && wget --directory-prefix=${GRADLE_FILE_SAVE_HOME} ${GRADLE_FILE_URL} \
    && mkdir -p ${GRADLE_FILE_SAVE_HOME}/${GRADLE_FILE_EXTRACT_DIR} \
    && unzip ${GRADLE_FILE_SAVE_HOME}/${GRADLE_FILE_NAME} -d ${GRADLE_FILE_SAVE_HOME} \
	&& rm -f ${GRADLE_FILE_SAVE_HOME}/${GRADLE_FILE_NAME} \	
    && mkdir ${GRADLE_WORK_HOME} \
    && alternatives --install /usr/bin/gradle gradle ${GRADLE_HOME}/bin/gradle 1 \
    && echo "init android dir." \
    && mkdir -p ${ANDROID_HOME} \
    && echo "remote openjdk." \
    && openjdks=$(rpm -aq | grep java-1.*);for it in $openjdks; do rpm -e --nodeps $it; done; \
    && echo "end." \
    && chown -R ${WORK_USER_NAME} ${MAVEN_FILE_SAVE_PATH} ${GRADLE_FILE_SAVE_HOME} ${GRADLE_WORK_HOME} 

VOLUME ${ANDROID_HOME}
VOLUME ${GRADLE_WORK_HOME}

#COPY android ${ANDROID_HOME}