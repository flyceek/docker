FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ARG JAVA_VERSION=8u151
ARG JAVA_JRE_VERSION=8.151.12-r0

ENV LANG C.UTF-8
ENV JAVA_HOME_DIR=/usr/lib/jvm/java-1.8-openjdk
ENV JAVA_HOME=${JAVA_HOME_DIR}/jre
ENV PATH ${PATH}:${JAVA_HOME}/bin:${JAVA_HOME_DIR}/bin

RUN { \
		echo '#!/bin/sh'; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home \
	&& apk add --no-cache openjdk8-jre="$JAVA_JRE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]