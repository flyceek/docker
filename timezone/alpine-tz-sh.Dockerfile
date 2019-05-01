FROM alpine:3.6
MAINTAINER flyceek <flyceek@gmail.com>

ENV TIME_ZONE=Asia/Shanghai

RUN apk --update add --no-cache tzdata \
	&& cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime \
	&& echo ${TIME_ZONE} > /etc/timezone \
	&& apk --update del tzdata