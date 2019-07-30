FROM debian:stretch
MAINTAINER flyceek <flyceek@gmail.com>

ARG WORK_HOME=/opt/soft/xtrabackup
ARG XTRABACKUP_VERSION=8.0.4
ARG XTRABACKUP_FILE_NAME=percona-xtrabackup-80_${XTRABACKUP_VERSION}-1.stretch_amd64.deb
ARG XTRABACKUP_FILE_URL=https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-${XTRABACKUP_VERSION}/binary/debian/stretch/x86_64/${XTRABACKUP_FILE_NAME}

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
    