FROM openjdk:8u212-alpine

MAINTAINER flyceek "flyceek@gmail.com"

ENV SMS_WORKDIR=/opt/spring-message-service
ENV SMS_VERSION=1.0.1
ENV SMS_FILE_NAME=spring-msg-service-v${SMS_VERSION}.jar
ENV SMS_FILE_URL=https://github.com/flyceek/spring-message-service/releases/download/v${SMS_VERSION}/${SMS_FILE_NAME}


RUN apk --update add --no-cache wget \
    && mkdir -p ${SMS_WORKDIR} \
    && cd ${SMS_WORKDIR} \
    && wget -O ${SMS_FILE_NAME} ${SMS_FILE_URL} \
    && echo 'create kafka-rongyun-private-message-consumer launch.' \
    && { \
		echo '#!/bin/sh'; \
		echo 'cd '${SMS_WORKDIR}; \
        echo 'java -jar -Dspring.profiles.active=kafka,kafka-rongyun-private-message-consumer,kafka-rongyun-private-message-service,rongyun '${SMS_FILE_NAME}; \
	} > /usr/local/bin/rongyun-private-message-consumer \
    && chmod +x /usr/local/bin/rongyun-private-message-consumer \
    && echo 'create kafka-rongyun-private-message-producer launch.' \
    && { \
		echo '#!/bin/sh'; \
		echo 'cd '${SMS_WORKDIR}; \
        echo 'java -jar -Dspring.profiles.active=kafka,kafka-producer,kafka-rongyun-private-message-producer,kafka-rongyun-private-message-service,rongyun '${SMS_FILE_NAME}; \
	} > /usr/local/bin/rongyun-private-message-producer \
    && chmod +x /usr/local/bin/rongyun-private-message-producer \
    && echo 'create kafka-rongyun-system-message-consumer launch.' \
    && { \
		echo '#!/bin/sh'; \
		echo 'cd '${SMS_WORKDIR}; \
        echo 'java -jar -Dspring.profiles.active=kafka,kafka-rongyun-system-message-consumer,kafka-rongyun-system-message-service,rongyun '${SMS_FILE_NAME}; \
	} > /usr/local/bin/rongyun-system-message-consumer \
    && chmod +x /usr/local/bin/rongyun-system-message-consumer \
    && echo 'create kafka-rongyun-system-message-producer launch.' \
    && { \
		echo '#!/bin/sh'; \
		echo 'cd '${SMS_WORKDIR}; \
        echo 'java -jar -Dspring.profiles.active=kafka,kafka-producer,kafka-rongyun-system-message-producer,kafka-rongyun-system-message-service,rongyun '${SMS_FILE_NAME}; \
	} > /usr/local/bin/rongyun-system-message-producer \
    && chmod +x /usr/local/bin/rongyun-system-message-producer \
    && echo 'create kafka-rongyun-system-group-producer launch.' \
    && { \
		echo '#!/bin/sh'; \
		echo 'cd '${SMS_WORKDIR}; \
        echo 'java -jar -Dspring.profiles.active=kafka,kafka-producer,kafka-rongyun-group-message-producer,kafka-rongyun-group-message-service,rongyun '${SMS_FILE_NAME}; \
	} > /usr/local/bin/rongyun-group-message-producer \
    && chmod +x /usr/local/bin/rongyun-group-message-producer \
    && echo 'create kafka-rongyun-system-group-consumer launch.' \
    && { \
		echo '#!/bin/sh'; \
		echo 'cd '${SMS_WORKDIR}; \
        echo 'java -jar -Dspring.profiles.active=kafka,kafka-rongyun-group-message-consumer,kafka-rongyun-group-message-service,rongyun '${SMS_FILE_NAME}; \
	} > /usr/local/bin/rongyun-group-message-consumer \
    && chmod +x /usr/local/bin/rongyun-group-message-consumer \
    && echo "root:123321" | chpasswd

WORKDIR ${SMS_WORKDIR}