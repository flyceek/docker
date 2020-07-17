FROM openjdk:8-jdk

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}

ENV TINI_VERSION 0.19.0
ENV TINI_SHA c5b0666b4cb676901f90dfcb37106783c5fe2077b04590973b885950611b30ee

ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.245}

ARG JENKINS_SHA=c61e239b6c52a0db9de5868b11964b2838de8ba8f2f1a5933e5fa61f088a333c
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy
COPY jenkins-support /usr/local/bin/jenkins-support

COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY plugins.sh /usr/local/bin/plugins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh

VOLUME /var/jenkins_home

RUN apt-get update && apt-get install -y git curl && rm -rf /var/lib/apt/lists/* \
  && groupadd -g ${gid} ${group} \
  && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user} \
  && mkdir -p /usr/share/jenkins/ref/init.groovy.d \
  && curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha256sum -c - \
  && curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c - \
  && chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref \
  && chown -R ${user} /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy \
  && chown -R ${user} /usr/local/bin/jenkins-support \
  && chown -R ${user} /usr/local/bin/jenkins.sh \
  && chown -R ${user} /usr/local/bin/plugins.sh \
  && chown -R ${user} /usr/local/bin/install-plugins.sh

EXPOSE ${http_port}
EXPOSE ${agent_port}

USER ${user}
#ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]