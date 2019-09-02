FROM openjdk:8-jre-alpine
MAINTAINER flyceek <flyceek@gmail.com>

ENV SENTINEL_VERSION=1.6.2
ENV SENTINEL_FILE_NAME=sentinel-dashboard-apollo-v${SENTINEL_VERSION}.jar
ENV SENTINEL_FILE_URL=https://github.com/flyceek/sentinel/releases/download/v${SENTINEL_VERSION}/${SENTINEL_FILE_NAME}
ENV SENTINEL_PORT=8080
ENV SENTINEL_IP=127.0.0.1
ENV MEM_LIMIT=1024m

RUN set -x \
    && apk upgrade --update \
	&& apk add wget bash \
    && mkdir -p /opt/ \
    && cd /opt/ \
    && wget ${SENTINEL_FILE_URL} \
    && { \
		echo '#!/bin/sh'; \
        echo 'cd /opt/'; \
        echo 'java -Dserver.port='${SENTINEL_PORT}' -Dserver.address='${SENTINEL_IP}' -Dsentinel.dashboard.version='${SENTINEL_VERSION}' -jar -Xmx'${MEM_LIMIT}' -Xms'${MEM_LIMIT}' '${SENTINEL_FILE_NAME}''; \
	} > /usr/local/bin/launch \
    && chmod +x /usr/local/bin/launch \
    && echo "root:123321" | chpasswd


EXPOSE ${SENTINEL_PORT}
ENTRYPOINT ["launch"]


