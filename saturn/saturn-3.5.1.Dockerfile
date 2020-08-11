FROM openjdk:8-jdk-alpine
MAINTAINER flyceek@gmail.com

COPY build.sh /build.sh

RUN ["sh","/build.sh","alpine","console","3.5.1"]

EXPOSE 9088