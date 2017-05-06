FROM flyceek/centos7-jdk:latest
MAINTAINER flyceek <flyceek@gmail.com>

ARG JENKINS_USER=flyceek
ARG JENKINS_USER_PWD=flyceek
ARG JENKINS_USER_GROUP=flyceek
ARG JENKINS_USER_UID=1069
ARG JENKINS_USER_GID=1069

ARG JENKINS_VERSION=2.9
ARG JENKINS_FILE_NAME=jenkins-war-${JENKINS_VERSION}.war
ARG JENKINS_FILE_SHA=1fd02a942cca991577ee9727dd3d67470e45c031
ARG JENKINS_FILE_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/${JENKINS_FILE_NAME}

ENV JENKINS_HOME=/home/jenkins
ENV JENKINS_HTTP_PORT=8080
ENV JENKINS_OPTIONS=--httpPort=${JENKINS_HTTP_PORT}
ENV JENKINS_JAVA_OPTIONS=-Xmx512m

WORKDIR ${JENKINS_HOME}
RUN yum update -y \
    && yum install -y sudo \
    && yum clean all \
    && groupadd --system -g ${JENKINS_USER_GID} ${JENKINS_USER_GROUP} \
    && useradd --system -d "${JENKINS_HOME}" -u ${JENKINS_USER_UID} -g ${JENKINS_USER_GID} -m -s /bin/bash ${JENKINS_USER} \
    && usermod -aG wheel ${JENKINS_USER} \
    && chmod a+w /etc/sudoers \
    && echo "${JENKINS_USER} ALL=(ALL) ALL" >> /etc/sudoers \
    && chown -R ${JENKINS_USER} "${JENKINS_HOME}" \
    && echo "${JENKINS_USER}:${JENKINS_USER_PWD}" | chpasswd \
    && chmod a-w /etc/sudoers \
    && curl -O ${JENKINS_FILE_URL} \
    && echo "${JENKINS_FILE_SHA} ${JENKINS_FILE_NAME}" | sha1sum -c - \
    && echo "java ${JENKINS_JAVA_OPTIONS} -jar ${JENKINS_FILE_NAME} ${JENKINS_OPTIONS}" >> run.sh \
    && chown -R ${JENKINS_USER} "${JENKINS_HOME}" 

USER ${JENKINS_USER}
EXPOSE ${JENKINS_HTTP_PORT}
CMD ["sh","run.sh"]