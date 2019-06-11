FROM openjdk:8-jre-alpine
MAINTAINER flyceek <flyceek@gmail.com>

COPY build.sh /build.sh

RUN ["sh","/build.sh","1.4","apollo","configservice"]

USER apollo
EXPOSE 8080
CMD ["apollo-configservice-start"] 