FROM openjdk:8-jre-alpine
MAINTAINER flyceek <flyceek@gmail.com>

COPY build.sh /build.sh

RUN ["sh","/build.sh","1.5.1","apollo","adminservice","0068eb6fc69dc49b035daf0d88d6ae3e631c03b8"]

USER apollo
EXPOSE 8090
CMD ["apollo-adminservice-start"] 