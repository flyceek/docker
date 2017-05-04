FROM flyceek/centos7-jdk:latest
MAINTAINER flyceek <flyceek@gmail.com>

RUN yum update -y \
    && yum install -y sudo \
    && yum clean all

ARG JENKINS_USER_NAME=flyceek
ARG JENKINS_USER_PWD=flyceek
ARG JENKINS_USER_GROUP=flyceek
ARG JENKINS_USER_UID=1069
ARG JENKINS_USER_GID=1069
ENV JENKINS_USER_HOME=/var/jenkins_home

RUN groupadd --system -g ${JENKINS_USER_GID} ${JENKINS_USER_GROUP} \
    && useradd --system -d "${JENKINS_USER_HOME}" -u ${JENKINS_USER_UID} -g ${JENKINS_USER_GID} -m -s /bin/bash ${JENKINS_USER_NAME} \
    && usermod -aG wheel ${JENKINS_USER_NAME} \
    && chmod a+w /etc/sudoers \
    && echo "${JENKINS_USER_NAME} ALL=(ALL) ALL" >> /etc/sudoers \
    && chown -R ${JENKINS_USER_NAME} "${JENKINS_USER_HOME}" \
    && echo "${JENKINS_USER_NAME}:${JENKINS_USER_PWD}" | chpasswd \
    && chmod a-w /etc/sudoers

ARG JENKINS_VERSION=2.9
ARG JENKINS_FILE_NAME=jenkins-war-${JENKINS_VERSION}.war
ARG JENKINS_FILE_SHA=1fd02a942cca991577ee9727dd3d67470e45c031
ARG JENKINS_FILE_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/${JENKINS_FILE_NAME}

ENV JENKINS_FILE_SAVE_PATH=/opt/soft/jenkins
ENV JENKINS_HTTP_PORT=8080
ENV JENKINS_OPTIONS=--httpPort=${JENKINS_HTTP_PORT}
ENV JENKINS_JAVA_OPTIONS=-Xmx512m

WORKDIR ${JENKINS_FILE_SAVE_PATH}
RUN curl -O ${JENKINS_FILE_URL} \
    && echo "${JENKINS_FILE_SHA} ${JENKINS_FILE_NAME}" | sha1sum -c \
    && echo "java ${JENKINS_JAVA_OPTIONS} -jar ${JENKINS_FILE_NAME} ${JENKINS_OPTIONS}" >> run.sh \
    && chown -R ${JENKINS_USER_NAME} "${JENKINS_FILE_SAVE_PATH}" 

USER ${JENKINS_USER_NAME}
EXPOSE ${JENKINS_HTTP_PORT}
CMD ["sh","run.sh"]