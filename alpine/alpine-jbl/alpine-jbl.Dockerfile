FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ENV JBL_PORT=8088
WORKDIR /opt/soft/jbl/
COPY lightjbl-linux-64 /opt/soft/jbl/
CMD ./lightjbl-linux-64 -v -p ${JBL_PORT} -u flyceek -t 365