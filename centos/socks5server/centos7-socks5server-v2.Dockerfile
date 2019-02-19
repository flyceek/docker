FROM centos:latest
MAINTAINER flyceek "flyceek@gmail.com"

ARG SS5_WORKDIR=/opt/soft/ss5
ARG SS5_SRC_DIR=${SS5_WORKDIR}/src
ARG SS5_VERSION=3.8.9-8
ARG SS5_FILE_NAME=ss5-${SS5_VERSION}.tar.gz
ARG SS5_FILE_URL=http://jaist.dl.sourceforge.net/project/ss5/ss5/${SS5_VERSION}/${SS5_FILE_NAME}

ENV SS5_USER=paranora
ENV SS5_PASSWD=123321

RUN yum update -y \
    && yum install -y gcc automake make openldap-devel pam-devel cyrus-sasl-devel openssl-devel wget \
    && mkdir -p ${SS5_SRC_DIR} \
    && cd ${SS5_WORKDIR} \
    && wget -O ${SS5_FILE_NAME} ${SS5_FILE_URL} \
    && tar -xzf ${SS5_FILE_NAME} -C ${SS5_SRC_DIR} --strip-components=1 \
    && rm ${SS5_FILE_NAME} \
    && cd ${SS5_SRC_DIR} \
    && ./configure \
    && make \
    && make install \
    && cd ${SS5_WORKDIR} \
    && rm -fr ${SS5_SRC_DIR} \
    && sed -i "/#auth/a\auth 0.0.0.0\/0 – u" /etc/opt/ss5/ss5.conf \
    && sed -i "/#permit/a\permit u 0.0.0.0\/0 - 0.0.0.0\/0 - - - - -" /etc/opt/ss5/ss5.conf \
    && touch /var/log/ss5/ss5.log \
    && { \
		echo '#!/bin/sh'; \
		echo 'echo ${SS5_USER} ${SS5_PASSWD} > /etc/opt/ss5/ss5.passwd'; \
        echo 'ss5 -t -u root'; \
        echo 'tail -f /var/log/ss5/ss5.log'; \
	} > /usr/local/bin/ss5-start \
    && chmod +x /usr/local/bin/ss5-start \
    && echo "root:123321" | chpasswd

EXPOSE 1080
WORKDIR ${SS5_WORKDIR}
ENTRYPOINT ["ss5-start"]