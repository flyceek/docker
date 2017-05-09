FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV PATH=$PATH:${JAVA_HOME}/jre/bin:${JAVA_HOME}/bin

RUN apk --update add --no-cache openjdk8-jre