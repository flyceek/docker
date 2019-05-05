#!/bin/sh
SYSTEM=$1
JDK_VER=$2
JDK_UPDATE=$3
JDK_BUILD=$4
JDK_URLID=$5
JDK_SHA256=$6
AUTH_PARAM=$7

JDK_SAVE_PATH=/opt/soft/java/jdk
JDK_ED=${JDK_VER}u${JDK_UPDATE}
JDK_FILE_NAME=jdk-${JDK_ED}-linux-x64.tar.gz
JDK_FILE_EXTRACT_DIR=jdk1.${JDK_VER}.0_${JDK_UPDATE}
JAVA_HOME=${JDK_SAVE_PATH}/${JDK_FILE_EXTRACT_DIR}
JDK_URL=http://download.oracle.com/otn/java/jdk/${JDK_ED}-${JDK_BUILD}/${JDK_URLID}/${JDK_FILE_NAME}?AuthParam=${AUTH_PARAM}

if [ -z "$AUTH_PARAM" ]; then
    echo 'auth param is empty!'
    exit 1
fi

function installCentaOSDependencies(){
    yum update -y
    yum install -y tar.x86_64 wget
}

function installAlpineDependencies(){
    apk --update add --no-cache --virtual=.build-dependencies wget ca-certificates unzip
}

function setCentaOSSystem(){
    installCentaOSDependencies
}

function setAlpineSystem(){
    installAlpineDependencies
}

function setSystemUser(){
    echo "root:123321" | chpasswd
}

function installJdk(){
    mkdir -p ${JAVA_HOME}
    cd ${JDK_SAVE_PATH}
    local path=$(pwd)
    echo 'begin download jdk in path :'${path}', url :'${JDK_URL}'.'
    #curl -O ${JDK_FILE_NAME} -L -H "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" ${JDK_URL} 
    wget -O ${JDK_FILE_NAME} --no-cookies --no-check-certificate --header "Cookie: gpw_e24=https%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk8-downloads-2133151.html; oraclelicense=accept-securebackup-cookie;" ${JDK_URL}
    echo "${JDK_SHA256} ${JDK_FILE_NAME}" | sha256sum -c - 
    if [ $? -ne 0 ]; then
        echo 'file :'${JDK_FILE_NAME}', sha256 :'${JDK_SHA256}', is does not match!'
        exit 1
    fi
    tar -xvf ${JDK_FILE_NAME} -C ${JAVA_HOME} --strip-components=1
    if [ $? -ne 0 ]; then
        echo 'something wrong happened !'
        exit 1
    fi
}

function installAlpineJdk(){
    mkdir /tmp
    cd /tmp
    local GLIBC_VERSION='2.25-r0'
    local GLIBC_DOWNLOAD_URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}
    local GLIBC_FILE_NAME=glibc-${GLIBC_VERSION}.apk
    local GLIBC_FILE_URL=${GLIBC_DOWNLOAD_URL}/${GLIBC_FILE_NAME}
    local GLIBC_BIN_FILE_NAME=glibc-bin-${GLIBC_VERSION}.apk
    local GLIBC_BIN_FILE_URL=${GLIBC_DOWNLOAD_URL}/${GLIBC_BIN_FILE_NAME}
    local GLIBC_I18N_FILE_NAME=glibc-i18n-${GLIBC_VERSION}.apk
    local GLIBC_I18N_FILE_URL=${GLIBC_DOWNLOAD_URL}/${GLIBC_I18N_FILE_NAME}
    local GLIBC_SGERRAND_URL=https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub
    wget ${GLIBC_SGERRAND_URL} -O /etc/apk/keys/sgerrand.rsa.pub
    wget ${GLIBC_FILE_URL} ${GLIBC_BIN_FILE_URL} ${GLIBC_I18N_FILE_URL}
    apk add --no-cache ${GLIBC_FILE_NAME} ${GLIBC_BIN_FILE_NAME} ${GLIBC_I18N_FILE_NAME}

    installJdk
    
}

function setCentosJdk(){
    alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 1
    alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 1
    alternatives --install /usr/bin/jar jar ${JAVA_HOME}/bin/jar 1
}

function setJdk(){
    ln -s ${JAVA_HOME}/bin/java /usr/bin/java
    ln -s ${JAVA_HOME}/bin/javac /usr/bin/javac 
    ln -s ${JAVA_HOME}/bin/jar /usr/bin/jar
}

function clearSystem(){
    cd ${JDK_SAVE_PATH}
    rm -f ${JDK_FILE_NAME}
    rm -f ${JAVA_HOME}/*.zip
}

function clearAlpineSystem(){
    clearSystem
    rm -fr /tmp
    rm -fr /var/cache/apk/*
    rm /etc/apk/keys/sgerrand.rsa.pub
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true
    apk --update del glibc-i18n .build-dependencies
}

function installAlpine(){
    setAlpineSystem
    installAlpineJdk
    setJdk
    clearAlpineSystem
}

function installCentaOS(){
    setCentaOSSystem
    installJdk
    setCentosJdk
    clearSystem
}

function doAction(){
    if [ -z "$SYSTEM" ]; then
        echo 'system is empty!'
        exit 1
    fi
    case "$SYSTEM" in
    "alpine")
        echo "begin install jdk by alpine system."
        installAlpine
        ;;
    "centos")
        echo "begin install jdk by centos system."
        installCentaOS
        ;;
    *)
        echo "system error,please enter!"
        exit 1
        ;;
    esac
}

doAction
