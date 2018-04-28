FROM centos:latest
MAINTAINER flyceek <flyceek@gmail.com>

ENV WORK_HOME=/opt/soft/java/jdk
ENV JRE_VERSION_MAJOR=8
ENV JRE_VERSION_MINOR=172
ENV JRE_VERSION_BUILD=11
ARG JRE_SHA256=3d0a5db2300423a1fd6ee25c229dbd5320d79204c73844337f5b6a082d58541f

ENV JRE_FILE_NAME=server-jre-${JRE_VERSION_MAJOR}u${JRE_VERSION_MINOR}-linux-x64.tar.gz
ENV JRE_FILE_EXTRACT_DIR=jdk1.${JRE_VERSION_MAJOR}.0_${JRE_VERSION_MINOR}
ENV JRE_FILE_URL_HASH=a58eab1ec242421181065cdc37240b08
ENV JRE_FILE_URL=http://download.oracle.com/otn-pub/java/jdk/${JRE_VERSION_MAJOR}u${JRE_VERSION_MINOR}-b${JRE_VERSION_BUILD}/${JRE_FILE_URL_HASH}/${JRE_FILE_NAME}

ENV HOME=${WORK_HOME}/${JRE_FILE_EXTRACT_DIR}
ENV JRE_HOME=${HOME}/jre
ENV CLASSPATH=.:${HOME}/lib/dt.jar:${HOME}/lib/tools.jar
ENV PATH=${PATH}:${HOME}/bin:${JRE_HOME}/bin

RUN yum update -y \
    && yum install -y tar.x86_64 wget \
    && yum clean all \
    && mkdir -p ${HOME} \
    && cd ${WORK_HOME} \
    && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" ${JRE_FILE_URL} \
    && echo "${JRE_SHA256} ${JRE_FILE_NAME}" | sha256sum -c - \
    && tar -xvf ${JRE_FILE_NAME} -C ${HOME} --strip-components=1 \
    && alternatives --install /usr/bin/java java ${HOME}/bin/java 1 \
    && alternatives --install /usr/bin/javac javac ${HOME}/bin/javac 1 \
    && alternatives --install /usr/bin/jar jar ${HOME}/bin/jar 1 \
    && rm -f ${JRE_FILE_NAME} \
    && echo "root:123321" | chpasswd