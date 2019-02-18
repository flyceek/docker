FROM centos:latest
MAINTAINER flyceek "flyceek@gmail.com"

ARG WORKDIR=/opt/soft/socks5
ARG INSTALL_FILE_NAME=install.sh
ARG INSTALL_FILE_URL=https://raw.github.com/Lozy/danted/master/${INSTALL_FILE_NAME}


RUN yum update -y \
    && yum install -y wget \
    && mkdir -p ${WORKDIR} \
    && cd ${WORKDIR} \
    && wget --no-check-certificate ${INSTALL_FILE_URL} -O ${INSTALL_FILE_NAME} \
    && { \
		echo '#!/bin/sh'; \
		echo 'sh ${WORKDIR}/${INSTALL_FILE_NAME}'; \
	} > /usr/local/bin/ss5-install \
    && chmod +x /usr/local/bin/ss5-install \
    && yum clean all \
    && echo "root:123321" | chpasswd

WORKDIR ${WORKDIR}

ENTRYPOINT ["ss5-install"]