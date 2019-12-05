FROM openjdk:8-jre-alpine
MAINTAINER flyceek <flyceek@gmail.com>

COPY build.sh /build.sh

RUN ["sh","/build.sh","1.5.1","apollo","configservice","a7102ebe91b68a78abaa79bc0a2392495506fdc8"]

USER apollo
EXPOSE 8080
CMD ["apollo-configservice-start"] 