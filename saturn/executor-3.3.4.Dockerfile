FROM openjdk:8-jdk-alpine
MAINTAINER flyceek@gmail.com

COPY build.sh /build.sh

RUN ["sh","/build.sh","alpine","executor","3.3.4"]

ENTRYPOINT ["/usr/local/bin/launch"]