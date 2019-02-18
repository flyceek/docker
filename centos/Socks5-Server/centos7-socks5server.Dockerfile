FROM centos:latest
MAINTAINER flyceek "flyceek@gmail.com"

ARG SS5_WORKDIR=/opt/soft/socks5
ARG SS5_INSTALL_FILE_NAME=install.sh
ARG SS5_INSTALL_FILE_URL=https://raw.github.com/Lozy/danted/master/${SS5_INSTALL_FILE_NAME}

ENV SS5_INSTALL_PATH=${SS5_WORKDIR}/${SS5_INSTALL_FILE_NAME}

RUN yum update -y \
    && yum install -y wget \
    && mkdir -p ${SS5_WORKDIR} \
    && cd ${SS5_WORKDIR} \
    && wget --no-check-certificate ${SS5_INSTALL_FILE_URL} -O ${SS5_INSTALL_FILE_NAME} \
    && { \
		echo '#!/bin/sh'; \
        echo 'cd /opt/soft/socks5'; \
		echo 'bash install.sh'; \
	} > /usr/local/bin/ss5-install \
    && chmod +x /usr/local/bin/ss5-install \
    && yum clean all \
    && echo "root:123321" | chpasswd

ENTRYPOINT ["ss5-install"]