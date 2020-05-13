FROM openjdk:8u212-alpine

MAINTAINER flyceek "flyceek@gmail.com"

ARG MAVEN_FILE_SAVE_PATH=/opt/maven
ARG MAVEN_VERSION=3.6.3
ARG MAVEN_FILE_SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG MAVEN_FILE_NAME=apache-maven-${MAVEN_VERSION}-bin.tar.gz
ARG MAVEN_FILE_EXTRACT_DIR=apache-maven-${MAVEN_VERSION}
ARG MAVEN_FILE_URL=http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/${MAVEN_FILE_NAME}

ARG GRADLE_FILE_SAVE_HOME=/opt/gradle
ARG GRADLE_VERSION=6.4
ARG GRADLE_FILE_NAME=gradle-${GRADLE_VERSION}-bin.zip
ARG GRADLE_FILE_SHA=b888659f637887e759749f6226ddfcb1cb04f828c58c41279de73c463fdbacc9
ARG GRADLE_FILE_EXTRACT_DIR=gradle-${GRADLE_VERSION}
ARG GRADLE_FILE_URL=https://services.gradle.org/distributions/${GRADLE_FILE_NAME}


ENV SMS_WORKDIR=/opt/spring-message-service
ENV SMS_VERSION=1.0.1
ENV SMS_FILE_NAME=spring-msg-service-v${SMS_VERSION}.jar
ENV SMS_FILE_URL=https://github.com/flyceek/spring-message-service/releases/download/v${SMS_VERSION}/${SMS_FILE_NAME}

ARG SMS_GIT_URL=git@github.com:flyceek/spring-message-service.git

ENV MAVEN_HOME=${MAVEN_FILE_SAVE_PATH}/${MAVEN_FILE_EXTRACT_DIR}
ENV GRADLE_HOME=${GRADLE_FILE_SAVE_HOME}/${GRADLE_FILE_EXTRACT_DIR}
ENV PATH=${PATH}:${MAVEN_HOME}/bin:${GRADLE_HOME}/bin

RUN apk --update add --no-cache wget \
    && { \
        mkdir -p ${MAVEN_HOME}; \
        cd ${MAVEN_FILE_SAVE_PATH}; \
        wget --no-check-certificate --no-cookies ${MAVEN_FILE_URL}; \
        echo sha512sum ${MAVEN_FILE_NAME}; \
        if [ "${MAVEN_FILE_SHA}  ${MAVEN_FILE_NAME}" != "`sha512sum ${MAVEN_FILE_NAME}`" ]; then \
            echo 'maven file sha validate fail!'; \
            exit 999; \
        fi; \
        tar -zvxf ${MAVEN_FILE_NAME} -C ${MAVEN_HOME} --strip-components=1; \
        rm -f ${MAVEN_FILE_NAME}; \
        alternatives --install /usr/bin/mvn mvn ${MAVEN_HOME}/bin/mvn 1; \
    } \
    && { \
        mkdir -p ${GRADLE_HOME}; \
        cd ${GRADLE_FILE_SAVE_HOME}; \
        wget --no-check-certificate --no-cookies ${GRADLE_FILE_URL}; \
        echo sha512sum ${GRADLE_FILE_NAME}; \
        if [ "${GRADLE_FILE_SHA}  ${GRADLE_FILE_NAME}" != "`sha512sum ${GRADLE_FILE_NAME}`" ]; then \
            echo 'gradle file sha validate fail!'; \
            exit 999; \
        fi; \
        unzip ${GRADLE_FILE_NAME} -d ${GRADLE_FILE_SAVE_HOME}; \
	    rm -f ${GRADLE_FILE_NAME}; \
        alternatives --install /usr/bin/gradle gradle ${GRADLE_HOME}/bin/gradle 1; \
    } \
    &&{\
        mkdir -p ${SMS_WORKDIR} \
        cd ${SMS_WORKDIR} \
        git clone --depth=1 --single-branch --branch=master ${SMS_GIT_URL} \
        cd spring-message-service \
        gradle build -x test \
        mv spring-msg-service\out\libs\spring-msg-service-1.0.1-SNAPSHOT.jar ${SMS_FILE_NAME} \
        cd ${SMS_WORKDIR} \
        rm -fr spring-message-service \
    }\
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
    && { \
        alternatives --remove /usr/bin/gradle gradle ${GRADLE_HOME}/bin/gradle \
        alternatives --remove /usr/bin/mvn mvn ${MAVEN_HOME}/bin/mvn \
        rm -fr /opt/maven \
        rm -fr /opt/gradle \
        rm -fr ~/.m2 \
        rm -fr ~/.gradle \        
    } \
    && echo "root:123321" | chpasswd

WORKDIR ${SMS_WORKDIR}