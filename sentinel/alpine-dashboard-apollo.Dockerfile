FROM openjdk:8-jre-alpine
MAINTAINER flyceek <flyceek@gmail.com>

ENV SENTINEL_VERSION=1.6.3
ENV SENTINEL_FILE_NAME=sentinel-dashboard-apollo-v${SENTINEL_VERSION}.jar
ENV SENTINEL_FILE_URL=https://github.com/flyceek/sentinel/releases/download/v${SENTINEL_VERSION}/${SENTINEL_FILE_NAME}
ENV SENTINEL_PORT=8080
ENV SENTINEL_IP=127.0.0.1
ENV APOLLO_CLUSTER='default'
ENV APOLLO_APPID=''
ENV APOLLO_PORTALURL=''
ENV APOLLO_NAMESPACE=''
ENV APOLLO_ENV='DEV'
ENV APOLLO_TOKEN=''
ENV JAVA_OPTS='-Xmx1024m -Xms1024m'

RUN set -x \
    && apk upgrade --update \
	&& apk add wget bash \
    && mkdir -p /opt/ \
    && cd /opt/ \
    && wget ${SENTINEL_FILE_URL} \
    && { \
		echo '#!/bin/sh'; \
        echo 'cd /opt/'; \
        echo 'java -Dserver.port=8080 -Dserver.address=${SENTINEL_IP} -Dsentinel.dashboard.version=${SENTINEL_VERSION} -Dapollo.cluster=${APOLLO_CLUSTER} -Dapollo.appId=${APOLLO_APPID} -Dapollo.portalUrl=${APOLLO_PORTALURL} -Dapollo.nameSpace=${APOLLO_NAMESPACE} -Dapollo.env=${APOLLO_ENV} -Dapollo.token=${APOLLO_TOKEN} ${JAVA_OPTS} -jar ${SENTINEL_FILE_NAME}'; \
	} > /usr/local/bin/launch \
    && chmod +x /usr/local/bin/launch \
    && echo "root:123321" | chpasswd

EXPOSE 8080
ENTRYPOINT ["launch"]


