FROM flyceek/alpine-openjdk:jdk-8u151
MAINTAINER flyceek <flyceek@gmail.com>

ARG JENKINS_USER=jenkins
ENV JENKINS_HOME=/var/jenkins
ARG JENKINS_USER_PWD=jenkins
ARG JENKINS_GROUP=jenkins
ARG JENKINS_UID=1000
ARG JENKINS_GID=1000

ARG JENKINS_VERSION=2.99
ARG JENKINS_GPG_KEY="9B7D32F2D50582E6"
ENV JENKINS_FILE_PATH='/opt/soft/jenkins'
ENV JENKINS_FILE_NAME=jenkins-war-${JENKINS_VERSION}.war
ARG JENKINS_FILE_ASC_NAME=${JENKINS_FILE_NAME}.asc
ARG JENKINS_FILE_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/${JENKINS_FILE_NAME}
ARG JENKINS_FILE_ASC_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/${JENKINS_FILE_ASC_NAME}

ENV JENKINS_HTTP_PORT=8080
ENV JENKINS_OPTIONS=--httpPort=${JENKINS_HTTP_PORT}
ENV JENKINS_JAVA_OPTIONS=-Xmx512m

RUN mkdir -p ${JENKINS_FILE_PATH} \
    && apk --update add --no-cache --virtual=.init-dependencies gnupg \
    && apk --update add --no-cache --virtual=.jenkins-dependencies bash git ttf-dejavu openssh-client \
    && addgroup -g ${JENKINS_GID} ${JENKINS_GROUP} \
    && adduser -h ${JENKINS_HOME} -u ${JENKINS_UID} -G ${JENKINS_GROUP} -s /bin/bash -D ${JENKINS_USER} \
    && chown -R ${JENKINS_USER} "${JENKINS_HOME}" \
    && echo "${JENKINS_USER}:${JENKINS_USER_PWD}" | chpasswd \
    && cd ${JENKINS_FILE_PATH} \
    && wget ${JENKINS_FILE_URL} \
    && wget ${JENKINS_FILE_ASC_URL} \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-key "${JENKINS_GPG_KEY}" ||  gpg --keyserver pgp.mit.edu --recv-keys "${JENKINS_GPG_KEY}" ||  gpg --keyserver keyserver.pgp.com --recv-keys "${JENKINS_GPG_KEY}" \
    && gpg --verify "${JENKINS_FILE_ASC_NAME}" "${JENKINS_FILE_NAME}" \
    && rm -rf "${JENKINS_FILE_ASC_NAME}" \
    && { \
		echo '#!/bin/sh'; \
		echo 'java ${JENKINS_JAVA_OPTIONS} -jar ${JENKINS_FILE_PATH}/${JENKINS_FILE_NAME} ${JENKINS_OPTIONS}'; \
	} > /usr/local/bin/jenkins-start \
    && chmod +x /usr/local/bin/jenkins-start \
    && chmod +x ${JENKINS_FILE_NAME} \
    && apk --update del .init-dependencies \
    && rm /var/cache/apk/*

VOLUME ${JENKINS_HOME}
USER ${JENKINS_USER}
EXPOSE ${JENKINS_HTTP_PORT}
CMD ["jenkins-start"] 