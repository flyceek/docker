FROM openjdk:8-jre-alpine
MAINTAINER flyceek <flyceek@gmail.com>

ENV SENTINEL_VERSION=1.6.2
ENV SENTINEL_FILE_NAME=sentinel-dashboard-apollo-v${SENTINEL_VERSION}.jar
ENV SENTINEL_FILE_URL=https://github.com/flyceek/sentinel/releases/download/v${SENTINEL_VERSION}/${SENTINEL_FILE_NAME}

RUN set -x \
    && apk upgrade --update \
	&& apk add wget bash \
    && mkdir -p /opt/ \
    && cd /opt/ \
    && wget ${SENTINEL_FILE_URL} \
    && { \
		echo '#!/bin/sh'; \
        echo 'cd /opt/'; \
        echo 'java -Dserver.port=8080 -Dsentinel.dashboard.version=1.6.2 -jar ${SENTINEL_FILE_NAME}'; \
	} > /usr/local/bin/launch \
    && chmod +x /usr/local/bin/launch \
    && echo "root:123321" | chpasswd


EXPOSE 8080
ENTRYPOINT ["launch"]


