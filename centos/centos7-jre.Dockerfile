FROM centos:centos7
MAINTAINER flyceek <flyceek@gmail.com>

ENV JAVA_WORK_HOME=/opt/soft/java
ENV JAVA_VERSION_MAJOR=8
ENV JAVA_VERSION_MINOR=141
ENV JAVA_VERSION_BUILD=15
ENV JAVA_JRE_FILE_NAME=server-jre-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz
ENV JAVA_JRE_FILE_EXTRACT_DIR=jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}
ENV JAVA_DOWNLOAD_HASH=336fa29ff2bb4ef291e347e091f7f4a7
ENV JAVA_DOWNLOAD_URL=http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_DOWNLOAD_HASH}/${JAVA_JRE_FILE_NAME}

ENV JAVA_HOME=${JAVA_WORK_HOME}/${JAVA_JRE_FILE_EXTRACT_DIR}
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar
ENV PATH=${PATH}:${JAVA_HOME}/bin:${JRE_HOME}/bin

RUN yum install -y curl tar \
    && yum clean all \
    && mkdir -p ${JAVA_WORK_HOME} \
    && curl --location --retry 3 --header "Cookie: oraclelicense=accept-securebackup-cookie; " ${JAVA_DOWNLOAD_URL} | gunzip | tar -x -C ${JAVA_WORK_HOME} \
    && alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 1 \
    && alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 1 \
    && alternatives --install /usr/bin/jar jar ${JAVA_HOME}/bin/jar 1 \
    && echo "root:123321" | chpasswd