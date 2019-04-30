FROM node:10.6-alpine
MAINTAINER flyceek <flyceek@gmail.com>

COPY build.sh /build.sh

RUN ["sh","/build.sh","1.7.0","yapi"]

USER yapi
EXPOSE 3000
CMD ["yapi-initdb-start"] 