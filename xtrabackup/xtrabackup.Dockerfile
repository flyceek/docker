FROM debian:jessie-slim
MAINTAINER flyceek <flyceek@gmail.com>

RUN apt-get -qq update \
    && apt-get install -y wget base-files lsb-release lsb-base \
    && wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/binary/debian/jessie/x86_64/percona-xtrabackup-24_2.4.4-1.jessie_amd64.deb \
    && sudo dpkg -i percona-xtrabackup-24_2.4.4-1.jessie_amd64.deb
    