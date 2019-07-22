FROM debian:jessie-slim
MAINTAINER flyceek <flyceek@gmail.com>

ARG WORK_HOME=/opt/soft/xtrabackup
ARG XTRABACKUP_VERSION=8.0.4
ARG XTRABACKUP_FILE_NAME=percona-xtrabackup-80_${XTRABACKUP_VERSION}-1.stretch_amd64.deb
ARG XTRABACKUP_FILE_URL=https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-${XTRABACKUP_VERSION}/binary/debian/stretch/x86_64/￥{XTRABACKUP_FILE_NAME}

RUN apt-get -qq update \
    && apt-get install -y wget base-files lsb-release lsb-base \
    && mkdir -p ${WORK_HOME} \
    && cd ${WORK_HOME} \
    && wget ${XTRABACKUP_FILE_NAME} \
    && sudo dpkg -i ${XTRABACKUP_FILE_NAME} \
    && rm -fr ${XTRABACKUP_FILE_NAME}
    