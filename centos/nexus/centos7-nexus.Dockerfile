FROM centos:centos7
MAINTAINER flyceek <flyceek@gmail.com>

ENV JAVA_WORK_HOME=/opt/soft/java
ENV JAVA_VERSION_MAJOR=8
ENV JAVA_VERSION_MINOR=141
ENV JAVA_VERSION_BUILD=15
ENV JAVA_JRE_FILE_NAME=server-jre-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz
ENV JAVA_JRE_FILE_EXTRACT_DIR=jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}
ENV JAVA_DOWNLOAD_HASH=336fa29ff2bb4ef291e347e091f7f4a7
ENV JAVA_DOWNLOAD_URL=http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_DOWNLOAD_HASH}/${JAVA_JRE_FILE_NAME}

ENV JAVA_HOME=${JAVA_WORK_HOME}/${JAVA_JRE_FILE_EXTRACT_DIR}
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar
ENV PATH=${PATH}:${JAVA_HOME}/bin:${JRE_HOME}/bin

ARG NEXUS_VERSION=3.5.1-02
ARG NEXUS_FILE_NAME=nexus-${NEXUS_VERSION}-unix.tar.gz
ARG NEXUS_FILE_EXTRACT_DIR=nexus-${NEXUS_VERSION}
ARG NEXUS_DOWNLOAD_URL=https://sonatype-download.global.ssl.fastly.net/nexus/3/${NEXUS_FILE_NAME}

ENV SONATYPE_DIR=/opt/soft/sonatype
ENV NEXUS_HOME=${SONATYPE_DIR}/nexus
ENV NEXUS_DATA=/var/nexus-data
ENV NEXUS_CONTEXT=''
ENV SONATYPE_WORK=${SONATYPE_DIR}/sonatype-work

ENV INSTALL4J_ADD_VM_PARAMS="-Xms1200m -Xmx1200m"

ENV NEXUS_DOMAIN=flyceek.org
ENV NEXUS_IP_ADDRESS=192.168.0.1
ENV NEXUS_PASSWORD=flyceek
ENV NEXUS_HTTP_PORT=8081
ENV NEXUS_HTTPS_PORT=8443

RUN yum install -y curl tar \
    && yum clean all \
    && mkdir -p ${JAVA_WORK_HOME} \
    && curl --location --retry 3 --header "Cookie: oraclelicense=accept-securebackup-cookie; " ${JAVA_DOWNLOAD_URL} | gunzip | tar -x -C ${JAVA_WORK_HOME} \
    && alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 1 \
    && alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 1 \
    && alternatives --install /usr/bin/jar jar ${JAVA_HOME}/bin/jar 1 \
    && mkdir -p ${NEXUS_HOME} ${NEXUS_DATA}/etc ${NEXUS_DATA}/log ${NEXUS_DATA}/tmp ${SONATYPE_WORK}\
    && chown -R root:root ${NEXUS_HOME} \
    && curl --location --retry 3 ${NEXUS_DOWNLOAD_URL} | gunzip | tar -x -C ${NEXUS_HOME} --strip-components=1 nexus-${NEXUS_VERSION} \
    && ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3 \
    && useradd -r -u 200 -m -c "nexus role account" -d ${NEXUS_DATA} -s /bin/bash nexus \
    && chown -R nexus:nexus ${NEXUS_DATA} ${SONATYPE_DIR} \
    && sed -e '/^nexus-context/ s:$:${NEXUS_CONTEXT}:' -i ${NEXUS_HOME}/etc/nexus-default.properties\
    && sed -e '/^-Xms/d' -e '/^-Xmx/d' -i ${NEXUS_HOME}/bin/nexus.vmoptions \
    && { \
        echo '#!/bin/sh'; \
        echo "sed 's:^application-port=\(.*\):application-port='"'${NEXUS_HTTP_PORT}'"':' -i ${NEXUS_HOME}/etc/nexus-default.properties"; \
        echo "sed '\$a\application-port-ssl='"'${NEXUS_HTTPS_PORT}'" -i ${NEXUS_HOME}/etc/nexus-default.properties"; \
        echo "sed 's/^nexus-args=\(.*\)/nexus-args=\${jetty.etc}\/jetty.xml,\${jetty.etc}\/jetty-http.xml,\${jetty.etc}\/jetty-requestlog.xml,\${jetty.etc}\/jetty-https.xml,\${jetty.etc}\/jetty-http-redirect-to-https.xml/' -i ${NEXUS_HOME}/etc/nexus-default.properties"; \
        echo "sed 's:<Set name=\"EndpointIdentificationAlgorithm\">\(.*\)<\/Set>:<Set name=\"EndpointIdentificationAlgorithm\">'"'${NEXUS_IP_ADDRESS}'"'<\/Set>:' -i ${NEXUS_HOME}/etc/jetty/jetty-https.xml"; \
        echo "sed 's:<Set name=\"KeyStorePassword\">\(.*\)<\/Set>:<Set name=\"KeyStorePassword\">'"'${NEXUS_PASSWORD}'"'<\/Set>:' -i ${NEXUS_HOME}/etc/jetty/jetty-https.xml"; \
        echo "sed 's:<Set name=\"KeyManagerPassword\">\(.*\)<\/Set>:<Set name=\"KeyManagerPassword\">'"'${NEXUS_PASSWORD}'"'<\/Set>:' -i ${NEXUS_HOME}/etc/jetty/jetty-https.xml"; \
        echo "sed 's:<Set name=\"TrustStorePassword\">\(.*\)<\/Set>:<Set name=\"TrustStorePassword\">'"'${NEXUS_PASSWORD}'"'<\/Set>:' -i ${NEXUS_HOME}/etc/jetty/jetty-https.xml"; \
        echo "sed 's:<Set name=\"KeyStorePath\"><Property name=\(.*\)/>\(.*\)<\/Set>:<Set name=\"KeyStorePath\"><Property name=\"ssl.etc\"/>\/keystore.jks<\/Set>:' -i ${NEXUS_HOME}/etc/jetty/jetty-https.xml"; \
        echo "sed 's:<Set name=\"TrustStorePath\"><Property name=\(.*\)/>\(.*\)<\/Set>:<Set name=\"TrustStorePath\"><Property name=\"ssl.etc\"/>\/keystore.jks<\/Set>:' -i ${NEXUS_HOME}/etc/jetty/jetty-https.xml"; \
        echo 'cd ${NEXUS_HOME}/etc/ssl'; \
        echo 'keytool -genkeypair -keystore ${NEXUS_HOME}/etc/ssl/keystore.jks -storepass '${NEXUS_PASSWORD}' -keypass '${NEXUS_PASSWORD}' -alias jetty -keyalg RSA -keysize 2048 -validity 5000 -dname "CN=*.${NEXUS_DOMAIN}, OU=flyceek-tech, O=flyceek, L=china-shanghai, ST=shanghai, C=CN" -ext "SAN=DNS:${NEXUS_DOMAIN},IP:${NEXUS_IP_ADDRESS}" -ext "BC=ca:true"'; \
        echo '${NEXUS_HOME}/bin/./nexus run'; \
	} > ${NEXUS_HOME}/nexus-https-start \
    && { \
        echo '#!/bin/sh'; \
        echo "sed 's:^application-port=\(.*\):application-port='"'${NEXUS_HTTP_PORT}'"':' -i ${NEXUS_HOME}/etc/nexus-default.properties"; \
        echo '${NEXUS_HOME}/bin/./nexus run'; \
	} > ${NEXUS_HOME}/nexus-http-start \
    && chmod +x ${NEXUS_HOME}/nexus-https-start ${NEXUS_HOME}/nexus-http-start \
    && echo "root:123321" | chpasswd

VOLUME ${NEXUS_DATA}
EXPOSE ${NEXUS_HTTP_PORT}
EXPOSE ${NEXUS_HTTPS_PORT}
USER nexus
WORKDIR ${NEXUS_HOME}

CMD ["./nexus-https-start"]