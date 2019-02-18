FROM centos:latest
MAINTAINER flyceek "flyceek@gmail.com"

ARG WORKDIR=/opt/soft/socks5
ARG INSTALL_FILE_URL=https://raw.github.com/Lozy/danted/master/install.sh

RUN yum update -y \
    && yum install -y wget \
    && mkdir -p ${WORKDIR} \
    && cd ${WORKDIR} \
    && wget --no-check-certificate ${INSTALL_FILE_URL} -O install.sh \
    && yum clean all \
    && echo "root:123321" | chpasswd

WORKDIR ${WORKDIR}

ENTRYPOINT ["install.sh"]