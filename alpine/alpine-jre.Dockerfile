FROM alpine:3.6
MAINTAINER flyceek <flyceek@gmail.com>

ARG JAVA_VERSION=8u131
ARG JAVA_ALPINE_VERSION=8.131.11-r2

ENV LANG C.UTF-8
ENV JAVA_HOME_DIR=/usr/lib/jvm/java-1.8-openjdk
ENV JAVA_HOME=${JAVA_HOME_DIR}/jre
ENV PATH ${PATH}:${JAVA_HOME}/bin:${JAVA_HOME_DIR}/bin

RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home \
    && set -x \
	&& apk add --no-cache openjdk8-jre="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]