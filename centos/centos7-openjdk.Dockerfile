FROM flyceek/centos7-jdk:latest
MAINTAINER flyceek <flyceek@gmail.com>

RUN yum update -y \
    && yum install -y java-1.8.0-openjdk-headless \
    && yum clean all