FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ARG JDK_VER=8 
ARG JDK_UPDATE=211
ARG JDK_BUILD=b12
ARG JDK_URL_ID=478a62b7d4e34b78b671c754eaaf38ab
ARG JDK_ED=${JDK_VER}u${JDK_UPDATE}

ARG JDK_FILE_SAVE_PATH=/opt/soft/java/jdk
ARG JDK_FILE_NAME=jdk-${JDK_ED}-linux-x64.tar.gz
ARG JDK_FILE_SHA256=28a00b9400b6913563553e09e8024c286b506d8523334c93ddec6c9ec7e9d346
ARG JDK_FILE_EXTRACT_DIR=jdk1.${JDK_VER}.0_${JDK_UPDATE}
ARG JDK_FILE_URL=http://download.oracle.com/otn-pub/java/jdk/${JDK_ED}-${JDK_BUILD}/${JDK_URL_ID}/${JDK_FILE_NAME}

ARG WORK_DIR='/tmp'

ENV GLIBC_VERSION='2.25-r0'
ARG GLIBC_DOWNLOAD_URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}
ARG GLIBC_FILE_NAME=glibc-${GLIBC_VERSION}.apk
ARG GLIBC_FILE_URL=${GLIBC_DOWNLOAD_URL}/${GLIBC_FILE_NAME}
ARG GLIBC_BIN_FILE_NAME=glibc-bin-${GLIBC_VERSION}.apk
ARG GLIBC_BIN_FILE_URL=${GLIBC_DOWNLOAD_URL}/${GLIBC_BIN_FILE_NAME}
ARG GLIBC_I18N_FILE_NAME=glibc-i18n-${GLIBC_VERSION}.apk
ARG GLIBC_I18N_FILE_URL=${GLIBC_DOWNLOAD_URL}/${GLIBC_I18N_FILE_NAME}
ARG GLIBC_SGERRAND_URL=https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub

ENV JAVA_HOME=${JDK_FILE_SAVE_PATH}/${JDK_FILE_EXTRACT_DIR}
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar
ENV PATH=${PATH}:${JAVA_HOME}/bin:${JRE_HOME}/bin

RUN apk --update add --no-cache --virtual=.build-dependencies wget ca-certificates unzip \
    && mkdir -p ${WORK_DIR} \
    && mkdir -p ${JAVA_HOME} \
    && cd ${WORK_DIR} \
    && wget ${GLIBC_SGERRAND_URL} -O /etc/apk/keys/sgerrand.rsa.pub \
    && wget ${GLIBC_FILE_URL} ${GLIBC_BIN_FILE_URL} ${GLIBC_I18N_FILE_URL} \
    && apk add --no-cache ${GLIBC_FILE_NAME} ${GLIBC_BIN_FILE_NAME} ${GLIBC_I18N_FILE_NAME} \
    && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" ${JDK_FILE_URL} \
    && echo "${JDK_FILE_SHA256}  ${JDK_FILE_NAME}" | sha256sum -c - \
    && tar -xvf ${JDK_FILE_NAME} -C ${JAVA_HOME} --strip-components=1 \
    && ln -s ${JAVA_HOME}/bin/java /usr/bin/java \
    && ln -s ${JAVA_HOME}/bin/javac /usr/bin/javac \
    && ln -s ${JAVA_HOME}/bin/jar /usr/bin/jar \
    && rm -f ${JAVA_HOME}/*.zip \
    && rm -fr ${WORK_DIR}/* \
    && rm -fr /var/cache/apk/* \
    && rm /etc/apk/keys/sgerrand.rsa.pub \
    && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true \
    && apk --update del glibc-i18n .build-dependencies\
    && cd / \
    && echo "root:123321" | chpasswd
