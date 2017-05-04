FROM flyceek/centos7-jdk:latest
MAINTAINER flyceek <flyceek@gmail.com>

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

ARG GIT_HOME_PATH=/opt/soft/git
ARG GIT_VERSION=2.9.3
ARG GIT_MAKE_PATH=${GIT_HOME_PATH}/${GIT_VERSION}
ARG GIT_FILENAME=git-${GIT_VERSION}.tar.gz
ARG GIT_FILE_SHA256=a252b6636b12d5ba57732c8469701544c26c2b1689933bd1b425e603cbb247c0
ARG GIT_FILE_EXTRACT_DIR=git-${GIT_VERSION}
ARG GIT_FILE_URL=https://www.kernel.org/pub/software/scm/git/${GIT_FILENAME}

ENV MAVEN_HOME=${MAVEN_FILE_SAVE_PATH}/${MAVEN_FILE_EXTRACT_DIR}
ENV GRADLE_HOME=${GRADLE_FILE_SAVE_HOME}/${GRADLE_FILE_EXTRACT_DIR}
ENV ANDROID_HOME=/opt/soft/android
ENV GIT_HOME=${GIT_HOME_PATH}/${GIT_FILE_EXTRACT_DIR}
ENV PATH=${PATH}:${MAVEN_HOME}/bin:${GRADLE_HOME}/bin::${GIT_HOME}/bin

RUN RUN yum update -y \
    && yum install -y unzip lsof wget \
    && yum install -y gcc glibc.i686 zlib.i686 libstdc++.i686 \
    && yum install -y gcc-c++ curl-devel expat-devel gettext-devel openssl-devel zlib-devel  perl-ExtUtils-MakeMaker \
    && yum install -y automake autoconf libtool make \
    && yum clean all \
    && mkdir -p ${MAVEN_HOME} \
    && wget --no-check-certificate --no-cookies --directory-prefix=${MAVEN_FILE_SAVE_PATH} ${MAVEN_FILE_URL} \
    && echo "${MAVEN_FILE_SHA} ${MAVEN_FILE_SAVE_PATH}/${MAVEN_FILE_NAME}" | sha1sum -c - \
    && tar -zvxf ${MAVEN_FILE_SAVE_PATH}/${MAVEN_FILE_NAME} -C ${MAVEN_HOME} --strip-components=1 \
    && rm -f ${MAVEN_FILE_SAVE_PATH}/${MAVEN_FILE_NAME} \
    && alternatives --install /usr/bin/mvn mvn ${MAVEN_HOME}/bin/mvn 1 \
    && mkdir -p ${GRADLE_HOME} \
    && mkdir ${GRADLE_WORK_HOME} \
    && wget --directory-prefix=${GRADLE_FILE_SAVE_HOME} ${GRADLE_FILE_URL} \
    && mkdir -p ${GRADLE_FILE_SAVE_HOME}/${GRADLE_FILE_EXTRACT_DIR} \
    && unzip ${GRADLE_FILE_SAVE_HOME}/${GRADLE_FILE_NAME} -d ${GRADLE_FILE_SAVE_HOME} \
	&& rm -f ${GRADLE_FILE_SAVE_HOME}/${GRADLE_FILE_NAME} \
    && alternatives --install /usr/bin/gradle gradle ${GRADLE_HOME}/bin/gradle 1 \
    && mkdir -p ${GIT_HOME} \
    && wget --no-check-certificate --no-cookies --directory-prefix=${GIT_HOME_PATH} ${GIT_FILE_URL} \
    && echo "${GIT_FILE_SHA256} ${GIT_HOME_PATH}/${GIT_FILENAME}" | sha256sum -c \
    && mkdir -p ${GIT_MAKE_PATH} \
    && tar -zvxf ${GIT_HOME_PATH}/${GIT_FILENAME} -C ${GIT_MAKE_PATH} --strip-components=1 \    
    && rm -f ${GIT_HOME_PATH}/${GIT_FILENAME} \
    && cd ${GIT_MAKE_PATH} \
    && ./configure --prefix=${GIT_HOME} \
    && make install \
    && make clean \
    && cd ${GIT_HOME_PATH} \
    && rm -fr ${GIT_MAKE_PATH} \
    && alternatives --install /usr/bin/git gradle ${GIT_HOME}/bin/git 1 \
    && mkdir -p ${ANDROID_HOME}

VOLUME ${ANDROID_HOME}
VOLUME ${GRADLE_WORK_HOME}