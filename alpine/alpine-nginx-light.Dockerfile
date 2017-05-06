FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

RUN apk update \
    && apk upgrade \
    && apk add nginx  \
    && mkdir /web && \
    && rm -rf /var/cache/apk/*

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]