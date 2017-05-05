FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ARG JDK_VER=8 
ARG JDK_UPD=131
ARG JDK_BUILD=b11
ARG JDK_URLID=d54c1d3a095b4ff2b6607d096fa80163
ARG JDK_ED=${JDK_VER}u${JDK_UPD}

ARG JDK_FILE_SAVE_PATH=/opt/soft/java/jdk
ARG JDK_FILE_NAME=jdk-${JDK_ED}-linux-x64.tar.gz
ARG JDK_FILE_SHA256=62b215bdfb48bace523723cdbb2157c665e6a25429c73828a32f00e587301236
ARG JDK_FILE_EXTRACT_DIR=jdk1.${JDK_VER}.0_${JDK_UPD}
ARG JDK_FILE_URL=http://download.oracle.com/otn-pub/java/jdk/${JDK_ED}-${JDK_BUILD}/${JDK_URLID}/${JDK_FILE_NAME}

ARG GLIBC_VERSION=2.25-r0
ARG GLIBC_FILE_NAME=glibc-${GLIBC_VERSION}.apk
ARG GLIBC_FILE_URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${GLIBC_FILE_NAME}
ARG WORK_DIR=/tmp

ENV JAVA_HOME=${JDK_FILE_SAVE_PATH}/${JDK_FILE_EXTRACT_DIR}
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar
ENV PATH=${PATH}:${JAVA_HOME}/bin:${JRE_HOME}/bin

RUN apk update \
    && apk upgrade \
    && apk add --no-cache --virtual=build-dependencies --update wget libstdc++ ca-certificates bash \
    && mkdir -p ${WORK_DIR} \
    && mkdir -p ${JAVA_HOME} \
    && cd ${WORK_DIR} \
    && wget --no-cookies --no-check-certificate ${GLIBC_FILE_URL} \
    && apk add --no-cache --allow-untrusted ${GLIBC_FILE_NAME} \
    && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" ${JDK_FILE_URL} \ 
    && echo "${JDK_FILE_SHA256}  ${JDK_FILE_NAME}" | sha256sum -c - \
    && tar -xvf ${JDK_FILE_NAME} -C ${JAVA_HOME} --strip-components=1 \
    && ln -s ${JAVA_HOME}/bin/java /usr/bin/java \
    && ln -s ${JAVA_HOME}/bin/javac /usr/bin/javac \
    && ln -s ${JAVA_HOME}/bin/jar /usr/bin/jar \
    && rm -f ${JAVA_HOME}/*.zip \
    && cd / \
    && rm -fr ${WORK_DIR}/* \
    && apk cache clean \
    && rm -fr /var/cache/apk/* \
    && echo "root:123321" | chpasswd
