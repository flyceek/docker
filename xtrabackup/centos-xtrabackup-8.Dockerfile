FROM centos:latest
MAINTAINER flyceek <flyceek@gmail.com>

ARG WORK_HOME=/opt/soft/xtrabackup

RUN yum update -y \
    && yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm \
    && percona-release enable-only tools release \
    && percona-release enable-only tools \
    && yum install -y percona-xtrabackup-80 \
    && mkdir -p ${WORK_HOME} \
    && cd ${WORK_HOME} \
    && echo "root:123321" | chpasswd
    