FROM openjdk:8u212-alpine

MAINTAINER flyceek "flyceek@gmail.com"

ENV SMS_WORKDIR=/opt/spring-message-service
ENV SMS_VERSION=1.0.2
ENV SMS_FILE_NAME=spring-msg-service-v${SMS_VERSION}.jar
ENV SMS_FILE_URL=https://github.com/flyceek/spring-message-service/releases/download/${SMS_VERSION}/${SMS_FILE_NAME}

RUN apk --update add --no-cache wget \
    && mkdir -p ${SMS_WORKDIR} \
    && cd ${SMS_WORKDIR} \
    && wget -O ${SMS_FILE_NAME} ${SMS_FILE_URL} \
    && { \
		echo '#!/bin/sh'; \
		echo 'cd '${SMS_WORKDIR}; \
        echo 'java -jar -Dspring.profiles.active=kafka,kafka-producer,rongyun '${SMS_FILE_NAME}; \
	} > /usr/local/bin/rongyun-message-producer \
    && chmod +x /usr/local/bin/rongyun-message-producer \
    && { \
		echo '#!/bin/sh'; \
		echo 'cd '${SMS_WORKDIR}; \
        echo 'java -jar -Dspring.profiles.active=kafka,kafka-consumer,${AA_KAFKA_CONSUMER_TYPE},rongyun '${SMS_FILE_NAME}; \
	} > /usr/local/bin/rongyun-message-consumer \
    && chmod +x /usr/local/bin/rongyun-message-consumer \
    && echo "root:123321" | chpasswd

WORKDIR ${SMS_WORKDIR}