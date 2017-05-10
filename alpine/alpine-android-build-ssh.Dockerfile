FROM flyceek/alpine-openjdk:jdk-8u121
MAINTAINER flyceek <flyceek@gmail.com>

ARG WORK_DIR='/tmp'

ENV GLIBC_VERSION='2.25-r0'
ARG GLIBC_DOWNLOAD_URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}
ARG GLIBC_FILE_NAME=glibc-${GLIBC_VERSION}.apk
ARG GLIBC_FILE_URL=${GLIBC_DOWNLOAD_URL}/${GLIBC_FILE_NAME}
ARG GLIBC_BIN_FILE_NAME=glibc-bin-${GLIBC_VERSION}.apk
ARG GLIBC_BIN_FILE_URL=${GLIBC_DOWNLOAD_URL}/${GLIBC_BIN_FILE_NAME}
ARG GLIBC_SGERRAND_URL=https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub

ARG MAVEN_FILE_SAVE_PATH=/opt/soft/mvn
ARG MAVEN_VERSION=3.5.0
ARG MAVEN_FILE_SHA=878b8b93a8f9685aefba5c21a17b46eb141b1122
ARG MAVEN_FILE_NAME=apache-maven-${MAVEN_VERSION}-bin.tar.gz
ARG MAVEN_FILE_EXTRACT_DIR=apache-maven-${MAVEN_VERSION}
ARG MAVEN_FILE_URL=http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/${MAVEN_FILE_NAME}

ARG GRADLE_FILE_SAVE_HOME=/opt/soft/gradle
ARG GRADLE_VERSION=2.14.1
ARG GRADLE_FILE_NAME=gradle-${GRADLE_VERSION}-bin.zip
ARG GRADLE_FILE_EXTRACT_DIR=gradle-${GRADLE_VERSION}
ARG GRADLE_FILE_URL=https://services.gradle.org/distributions/${GRADLE_FILE_NAME}


ENV MAVEN_HOME=${MAVEN_FILE_SAVE_PATH}/${MAVEN_FILE_EXTRACT_DIR}
ENV GRADLE_HOME=${GRADLE_FILE_SAVE_HOME}/${GRADLE_FILE_EXTRACT_DIR}
ENV ANDROID_HOME=/opt/soft/android-sdk
ENV PATH=${PATH}:${MAVEN_HOME}/bin:${GRADLE_HOME}/bin

RUN apk --update add --no-cache unzip wget gcc zlib libstdc++ ca-certificates \
    && apk add --update bash openssh openssh-client \
    && mkdir -p ${WORK_DIR} \
    && cd ${WORK_DIR} \
    && wget ${GLIBC_SGERRAND_URL} -O /etc/apk/keys/sgerrand.rsa.pub \
    && wget ${GLIBC_FILE_URL} ${GLIBC_BIN_FILE_URL} ${GLIBC_I18N_FILE_URL} \
    && apk add --no-cache ${GLIBC_FILE_NAME} ${GLIBC_BIN_FILE_NAME}  \
    && {\
        rm -rf /etc/ssh/ssh_host_*_key; \
        ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N '';  \
        ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ''; \
        ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''; \
        ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N ''; \
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config; \
        sed -i 's/#RSAAuthentication yes/RSAAuthentication yes/' /etc/ssh/sshd_config; \
        sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config; \
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config; \
        sed -i 's/#UsePAM yes/UsePAM no/' /etc/ssh/sshd_config; \
        mkdir -p /var/run/sshd; \
    } \    
    && { \
        mkdir -p ${MAVEN_HOME}; \
        cd ${MAVEN_FILE_SAVE_PATH}; \
        wget --no-check-certificate --no-cookies ${MAVEN_FILE_URL}; \
        echo sha1sum ${MAVEN_FILE_NAME}; \
        if [ "${MAVEN_FILE_SHA}  ${MAVEN_FILE_NAME}" != "`sha1sum ${MAVEN_FILE_NAME}`" ]; then \
            echo 'maven file sha validate fail!'; \
            exit 999; \
        fi; \
        tar -zvxf ${MAVEN_FILE_NAME} -C ${MAVEN_HOME} --strip-components=1; \
        rm -f ${MAVEN_FILE_NAME}; \
        ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn; \
    } \
    && { \
        mkdir -p ${GRADLE_HOME}; \
        cd ${GRADLE_FILE_SAVE_HOME}; \
        wget --no-check-certificate --no-cookies ${GRADLE_FILE_URL}; \
        unzip ${GRADLE_FILE_NAME} -d ${GRADLE_FILE_SAVE_HOME}; \
	    rm -f ${GRADLE_FILE_NAME}; \
        ln -s ${GRADLE_HOME}/bin/gradle /usr/bin/gradle; \
    } \
    && rm -fr ${WORK_DIR}/* \
    && rm -fr /var/cache/apk/* \
    && echo "root:123321" | chpasswd

VOLUME ${ANDROID_HOME}

EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]