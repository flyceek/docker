FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

COPY build.sh /build.sh

RUN ["sh","/build.sh","alpine","8","212","b10","59066701cf1a433da9770636fbc4c9aa","3160c50aa8d8e081c8c7fe0f859ea452922eca5d2ae8f8ef22011ae87e6fedfb","1557200309_5dc4aafc704bdf0a2d85d75b095da036"]
