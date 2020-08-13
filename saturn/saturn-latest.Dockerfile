FROM flyceek/jdk:8u251-centos7
MAINTAINER flyceek@gmail.com

COPY build.sh /build.sh

RUN ["sh","/build.sh","alpine"]
