FROM centos:centos7
MAINTAINER flyceek <flyceek@gmail.com>

ARG TEMP="/tmp"

RUN yum update -y && \
    yum install -y wget && \
    mkdir -p ${TEMP} && \
    cd ${TEMP} && \
    wget https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm && \
    rpm -Uvh erlang-solutions-1.0-1.noarch.rpm && \
    yum install -y erlang && \
    rm -fr ${TEMP} && \
    yum clean all

EXPOSE 4369