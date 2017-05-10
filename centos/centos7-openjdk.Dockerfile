FROM centos:centos7
MAINTAINER flyceek <flyceek@gmail.com>

RUN yum update -y \
    && yum install -y java-1.8.0-openjdk \
    && yum clean all