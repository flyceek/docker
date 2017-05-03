FROM centos:centos7
MAINTAINER flyceek <flyceek@gmail.com>

RUN yum update -y \
    && yum install -y tar.x86_64 wget \
    && yum clean all

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

ENV JAVA_HOME=${JDK_FILE_SAVE_PATH}/${JDK_FILE_EXTRACT_DIR}
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar
ENV PATH=${PATH}:${JAVA_HOME}/bin:${JRE_HOME}/bin

WORKDIR ${JDK_FILE_SAVE_PATH}
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" ${JDK_FILE_URL} \ 
    && echo "${JDK_FILE_SHA256} ${JDK_FILE_NAME}" | sha256sum -c \
    && mkdir -p ${JDK_FILE_EXTRACT_DIR} \
    && tar -xvf ${JDK_FILE_NAME} -C ${JDK_FILE_EXTRACT_DIR} --strip-components=1 \
    && rm -f ${JDK_FILE_SAVE_PATH}/${JDK_FILE_EXTRACT_DIR}/*.zip \
    && rm -f ${JDK_FILE_NAME} \
    && alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 1 \
    && alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 1 \
    && alternatives --install /usr/bin/jar jar ${JAVA_HOME}/bin/jar 1 \
    && echo "root:123321" | chpasswd