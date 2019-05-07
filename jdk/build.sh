#!/bin/sh
SYSTEM=$1
JDK_VER=$2
JDK_UPDATE=$3
JDK_BUILD=$4
JDK_URLID=$5
JDK_SHA256=$6
AUTH_PARAM=$7

JDK_DOWNLOAD_HEAES=""

JDK_SAVE_PATH=/opt/soft/java/jdk
JDK_ED=${JDK_VER}u${JDK_UPDATE}
JDK_FILE_NAME=jdk-${JDK_ED}-linux-x64.tar.gz
JDK_FILE_EXTRACT_DIR=jdk1.${JDK_VER}.0_${JDK_UPDATE}
JAVA_HOME=${JDK_SAVE_PATH}/${JDK_FILE_EXTRACT_DIR}
JDK_URL=https://download.oracle.com/otn/java/jdk/${JDK_ED}-${JDK_BUILD}/${JDK_URLID}/${JDK_FILE_NAME}?AuthParam=${AUTH_PARAM}

if [ -z "$AUTH_PARAM" ]; then
    echo 'auth param is empty!'
    exit 1001
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

function downloadCentOSJdk(){
    local heads=$1
    curl -o ${JDK_FILE_NAME} -L -H "${JDK_DOWNLOAD_HEAES}" ${JDK_URL} 
}

function downloadAlpineJdk(){
    local heads=$1
    # wget -O ${JDK_FILE_NAME} --no-cookies --no-check-certificate --header "${heads}" ${JDK_URL}
    wget -O ${JDK_FILE_NAME} --header "${JDK_DOWNLOAD_HEAES}" ${JDK_URL}
}

function prepareInstallJdk(){
    mkdir -p ${JAVA_HOME}
    cd ${JDK_SAVE_PATH}
    local path=$(pwd)
    JDK_DOWNLOAD_HEAES="Cookie: gpw_e24=https%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk8-downloads-2133151.html; oraclelicense=accept-securebackup-cookie"
    echo 'begin download jdk in path :'${path}', url :'${JDK_URL}'.'
}

function checkJdk(){
    if [ !-f "${JDK_FILE_NAME}" ]; then
        echo 'jdk file :'${JDK_FILE_NAME}' not found!'
        exit 1010
    fi
    local readJdkFIleSizeShell="ls -l ${JDK_FILE_NAME} | awk '{print "'$5'"}'"
    let waitTimes=5
    let currentWaitTimes=0
    let waitTimeInterval=1
    let lastJdkFIleSize=`eval ${readJdkFIleSizeShell}`
    let jdkFileSize=0
    echo 'begin wait jdk file write finish! , waitTimes :'${waitTimes}', waitTimeInterval:'${waitTimeInterval}'.'
    while [ ${currentWaitTimes} -lt ${waitTimes} ]
    do
        echo 'wait jdk file write finish , last file :'${JDK_FILE_NAME}', size:'${lastJdkFIleSize}', index :'${currentWaitTimes}'.'
        sleep ${waitTimeInterval}
        let jdkFileSize=`eval ${readJdkFIleSizeShell}`
        if [ ${jdkFileSize} -ne ${lastJdkFIleSize} ]; then
            echo 'jdk file :'${JDK_FILE_NAME}' , last file size :'${lastJdkFIleSize}', now is :'${jdkFileSize}', size is modify ,wait time add 3.'
            let waitTimes=${waitTimes}+3
        fi
        let lastJdkFIleSize=${jdkFileSize}
        let currentWaitTimes=${currentWaitTimes}+1
    done
    echo 'end wait jdk file write finish! , waitTimes :'${waitTimes}', waitTimeInterval:'${waitTimeInterval}'.'
    echo 'begin check jdk file sha256sum! , file :'${JDK_FILE_NAME}', sha256sum:'${JDK_SHA256}'.'
    echo "${JDK_SHA256}  ${JDK_FILE_NAME}" | sha256sum -c -
    if [ $? -ne 0 ]; then
        echo 'file :'${JDK_FILE_NAME}', sha256 :'${JDK_SHA256}', is does not match!'
        exit 1002
    fi
}

function storeJdk(){
    if [ !-f "${JDK_FILE_NAME}" ]; then
        echo 'jdk file :'${JDK_FILE_NAME}' not found!'
        exit 1010
    fi
    tar -xvf ${JDK_FILE_NAME} -C ${JAVA_HOME} --strip-components=1
    if [ $? -ne 0 ]; then
        echo 'something wrong happened !'
        exit 1003
    fi
}

function installCentOSJdk(){
    prepareInstallJdk
    downloadCentOSJdk
    checkJdk
    storeJdk
}

function installAlpineJdk(){
    prepareInstallJdk
    downloadAlpineJdk
    checkJdk
    storeJdk

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
}

function setCentOSJdk(){
    alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 1
    alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 1
    alternatives --install /usr/bin/jar jar ${JAVA_HOME}/bin/jar 1
}

function setJdk(){
    ln -s ${JAVA_HOME}/bin/java /usr/bin/java
    ln -s ${JAVA_HOME}/bin/javac /usr/bin/javac 
    ln -s ${JAVA_HOME}/bin/jar /usr/bin/jar
}

function setAlpineJdk(){
    setJdk
}

function clearSystem(){
    cd ${JDK_SAVE_PATH}
    rm -f ${JDK_FILE_NAME}
    rm -f ${JAVA_HOME}/*.zip
}

function clearCentOSSystem(){
    clearSystem
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
    installAlpineJdk
    setAlpineJdk
    setAlpineSystem
    clearAlpineSystem
}

function installCentaOS(){
    installCentOSJdk
    setCentOSJdk
    setCentaOSSystem
    clearCentOSSystem
}

function doAction(){
    if [ -z "$SYSTEM" ]; then
        echo 'system is empty!'
        exit 1004
    fi
    case "$SYSTEM" in
        "alpine")
            echo "begin install jdk by alpine system."
            installAlpine
            ;;
        "CentOS")
            echo "begin install jdk by CentOS system."
            installCentaOS
            ;;
        *)
            echo "system error,please enter!"
            exit 1005
            ;;
    esac
}

doAction
