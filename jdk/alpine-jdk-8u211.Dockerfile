FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

COPY build.sh /build.sh

RUN ["sh","/build.sh","alpine","8","211","b12","478a62b7d4e34b78b671c754eaaf38ab","c0b7e45330c3f79750c89de6ee0d949ed4af946849592154874d22abc9c4668d","1557109513_8f5ea2d24642355a5ed1729657c70f56"]
