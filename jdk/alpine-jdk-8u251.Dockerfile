FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

COPY build.sh /build.sh

RUN ["sh","/build.sh","alpine","8","251","b08","3d5a2bb8f8d4428bbe94aed7ec7ae784","777a8d689e863275a647ae52cb30fd90022a3af268f34fc5b9867ce32f1b374e","1589465490_d44df208a66741f2754905f352af24b4"]
