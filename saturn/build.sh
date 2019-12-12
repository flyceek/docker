#!/bin/sh
SYSTEM=$1
VERSION=$2

FILE_NAME=v${VERSION}.tar.gz
FILE_URL=https://github.com/vipshop/Saturn/archive/${FILE_NAME}

HOME=/opt/saturn/${VERSION}
SRC=${HOME}/src

function installCentOSDependencies(){
    yum update -y
    yum install -y tar.x86_64 wget maven
}

function installAlpineDependencies(){
    apk update upgrade 
    apk --update add --no-cache --virtual=.build-dependencies maven nodejs npm git
    apk --update add --no-cache wget chrony tzdata bash
}

function settingUpCentOS(){
    installCentOSDependencies
}

function settingUpAlpine(){
    installAlpineDependencies
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

function settingUpSystemUser(){
    echo "root:123321" | chpasswd
}

function download(){
    cd ${HOME}
    local path=$(pwd)
    local gitUrl=https://github.com/vipshop/Saturn.git
    echo 'begin download in path :'${path}', url :'${FILE_URL}'.'
    if [ -z "$VERSION" ]; then
        git clone --depth=1 --single-branch --branch=develop ${gitUrl} ${SRC}
    else
        wget -O ${FILE_NAME} ${FILE_URL}
        check
        if [ ! -f "${FILE_NAME}" ]; then
            echo 'install , relese src file :'${FILE_NAME}' not found!'
            exit 1010
        fi
        tar -xvf ${FILE_NAME} -C ${SRC} --strip-components=1
        rm -fr ${FILE_NAME}
    fi
    echo 'end download in path :'${path}', url :'${FILE_URL}'.'
}

function prepareInstall(){
    mkdir -p ${SRC}
    cd ${HOME}
    local path=$(pwd)
    echo 'prepare in path :'${path}', url :'${FILE_URL}'.'
}

function check(){
    cd ${HOME}
    local path=$(pwd)
    echo 'begin check file in path :'${path}', file : '${FILE_NAME}' , url :'${FILE_URL}'.'
    if [ ! -f "${FILE_NAME}" ]; then
        echo 'check file :'${FILE_NAME}' not found!'
        exit 1010
    fi
    local readFileSizeShell="ls -l ${FILE_NAME} | awk '{print "'$5'"}'"
    let waitTimes=5
    let currentWaitTimes=0
    let waitTimeInterval=1
    let lastFileSize=`eval ${readFileSizeShell}`
    let fileSize=0
    echo 'begin wait file write finish! , waitTimes :'${waitTimes}', waitTimeInterval:'${waitTimeInterval}'.'
    while [ ${currentWaitTimes} -lt ${waitTimes} ]
    do
        echo 'wait file write finish , last file :'${FILE_NAME}', size:'${lastFileSize}', index :'${currentWaitTimes}'.'
        sleep ${waitTimeInterval}
        let fileSize=`eval ${readFileSizeShell}`
        if [ ${fileSize} -ne ${lastFileSize} ]; then
            echo 'file :'${FILE_NAME}' , last file size :'${lastFileSize}', now is :'${fileSize}', size is modify ,wait time add 3.'
            let waitTimes=${waitTimes}+3
        fi
        let lastFileSize=${fileSize}
        let currentWaitTimes=${currentWaitTimes}+1
    done
    echo 'end wait file write finish! , waitTimes :'${waitTimes}', waitTimeInterval:'${waitTimeInterval}'.'
}

function install() {
    cd ${SRC}
    echo 'before modify pom.xml'
    cat pom.xml
    sed -i '/<artifactId>druid-wrapper<\/artifactId>/{n;s/<version>${druid.version}<\/version>/<version>${druid.version}<\/version><exclusions><exclusion><groupId>com.alibaba.druid<\/groupId><artifactId>druid<\/artifactId><\/exclusion><\/exclusions><\/dependency><dependency><groupId>com.alibaba<\/groupId><artifactId>druid<\/artifactId><version>1.1.21<\/version>/;}' pom.xml
    sed -i 's/<mysql.connector.java.version>5.1.34<\/mysql.connector.java.version>/<mysql.connector.java.version>8.0.18<\/mysql.connector.java.version>/g' pom.xml
    echo 'after modify pom.xml'
    cat pom.xml
    echo "begin install."
    mvn clean package -Dmaven.javadoc.skip=true -Dmaven.test.skip=true
    echo "end install."
}

function prepareConsoleLaunch(){
    cd ${SRC}
    local path=${HOME}/console/
    mkdir -p ${path}
    mv saturn-console/target/saturn-console-master-SNAPSHOT-exec.jar ${path}
    chmod +xr ${path}/saturn-console-master-SNAPSHOT-exec.jar
    echo -e '#!/bin/bash
chronyd
cd '${path}'
java ${CONSOLE_JAVA_OPTS} -jar saturn-console-master-SNAPSHOT-exec.jar'>/usr/local/bin/launch-console
    chmod +xr /usr/local/bin/launch-console
}

function prepareExecutorLaunch(){
    cd ${SRC}
    local path=${HOME}/executor/
    mkdir -p ${path}
    mv saturn-executor/target/saturn-executor-master-SNAPSHOT-zip.zip ${path}
    cd ${path}
    unzip -o saturn-executor-master-SNAPSHOT-zip.zip
    rm -fr saturn-executor-master-SNAPSHOT-zip.zip
    mv ./saturn-executor-master-SNAPSHOT/* ./
    rm -fr saturn-executor-master-SNAPSHOT
    chmod +xr saturn-executor*.jar
    chmod +xr ${path}/bin/*
    chmod +xr ${path}/lib/*
    echo -e '#!/bin/bash
chronyd
cd '${path}'
/bin/bash bin/saturn-executor.sh start -n ${EXECUTOR_NAMESPACE} -e ${EXECUTOR_NAME} -env ${EXECUTOR_ENV} -d ${EXECUTOR_LIBDIR} -r ${EXECUTOR_RUNMODE} -jmx ${EXECUTOR_JMXPORT} -sld "${EXECUTOR_LOGDIR}" ${EXECUTOR_JAVAOPTS}' >/usr/local/bin/launch-executor
    chmod +xr /usr/local/bin/launch-executor
}

function createLaunchShell(){
    prepareConsoleLaunch
    prepareExecutorLaunch
}

function installCentOSHandle(){
    prepareInstall
    download
    install
    createLaunchShell
}

function installAlpineHandle(){
    prepareInstall
    download
    install
    createLaunchShell
}

function settingUpCentOSFile(){
    echo "settingUpCentOSFile"
}

function settingUpAlpineFile(){
    echo "settingUpAlpineFile"
}

function clearSystem(){
    rm -fr ${SRC} \
    && rm -fr /root/.m2 \
    && rm -fr /build.sh
}

function cleanCentOS(){
    echo "begin clean centOS system."
    clearSystem
}

function cleanAlpine(){
    echo "begin clean alpine system."
    clearSystem
    apk --update del .build-dependencies
}

function installFromAlpine(){
    settingUpAlpine
    installAlpineHandle
    settingUpAlpineFile
    cleanAlpine
    settingUpSystemUser
}

function installFromCentOS(){
    settingUpCentOS
    installCentOSHandle
    settingUpCentOSFile
    cleanCentOS
    settingUpSystemUser
}

function doAction(){
    if [ -z "$SYSTEM" ]; then
        echo 'system is empty!'
        exit 1004
    fi

    case "$SYSTEM" in
        "alpine")
            echo "begin install by alpine system."
            installFromAlpine
            ;;
        "centos")
            echo "begin install by CentOS system."
            installFromCentOS
            ;;
        *)
            echo "system error,please enter!"
            exit 1005
            ;;
    esac
}

doAction
