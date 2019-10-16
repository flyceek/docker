FROM openjdk:8-jdk-alpine
MAINTAINER flyceek@gmail.com

COPY build.sh /build.sh

RUN ["sh","/build.sh","alpine","2.1.0"]

