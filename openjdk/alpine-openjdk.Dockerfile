FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ARG JAVA_VERSION=8u151
ARG JAVA_OPENJDK_VERSION=8.151.12-r0

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV PATH=$PATH:${JAVA_HOME}/jre/bin:${JAVA_HOME}/bin

RUN { \
		echo '#!/bin/sh'; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home \
	&& apk add --no-cache openjdk8="$JAVA_OPENJDK_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ] \
	&& rm -f /usr/local/bin/docker-java-home