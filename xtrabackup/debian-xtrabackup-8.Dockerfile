FROM debian:stretch
MAINTAINER flyceek <flyceek@gmail.com>

ARG WORK_HOME=/opt/soft/xtrabackup
ARG XTRABACKUP_VERSION=8.0.4

RUN apt-get update \
    && apt-get install -y wget vim lsb-release \
    && mkdir -p ${WORK_HOME} \
    && cd ${WORK_HOME} \
    && wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb \
    && dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb \
    && percona-release enable-only tools release \
    && percona-release enable-only tools \
    && apt-get update \
    && apt-get install -y percona-xtrabackup-80
    