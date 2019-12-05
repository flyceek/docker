FROM openjdk:8-jre-alpine
MAINTAINER flyceek <flyceek@gmail.com>

COPY build.sh /build.sh

RUN ["sh","/build.sh","1.5.1","apollo","portal","c0157c84392291bfd38b279993144e0db50e2d5b"]

USER apollo
EXPOSE 8070
CMD ["apollo-portal-start"] 