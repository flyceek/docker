#!/bin/sh
SYSTEM=$1
COMPONENT=$2
VERSION=$3

FILE_NAME=v${VERSION}.tar.gz
FILE_URL=https://github.com/vipshop/Saturn/archive/${FILE_NAME}
MAKE_DIR=saturn-console
MAKE_TARGET=saturn-console-master-SNAPSHOT-exec.jar

HOME=/opt/saturn
SRC=${HOME}/${VERSION}/src


if [ -z "$VERSION" ]; then
    echo 'version param is empty!'
    exit 1001
fi

function installCentOSDependencies(){
    yum update -y
    yum install -y tar.x86_64 wget maven
}

function installAlpineDependencies(){
    apk --update add --no-cache --virtual=.build-dependencies wget maven bash
}

function settingUpCentOS(){
    installCentOSDependencies
}

function settingUpAlpine(){
    installAlpineDependencies
}

function settingUpSystemUser(){
    echo "root:123321" | chpasswd
}

function download(){
    cd ${HOME}
    local path=$(pwd)
    echo 'begin download in path :'${path}', url :'${FILE_URL}'.'
    wget -O ${FILE_NAME} ${FILE_URL}
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
    cd ${HOME}
    if [ ! -f "${FILE_NAME}" ]; then
        echo 'install , file :'${FILE_NAME}' not found!'
        exit 1010
    fi
    tar -xvf ${FILE_NAME} -C ${SRC} --strip-components=1 \
    && rm -fr ${FILE_NAME} \
    && cd ${SRC}/${MAKE_DIR} \
    && mvn clean package -Dmaven.test.skip=true \
    && mv target/${MAKE_TARGET} ${HOME}/${VERSION}/ \
    && chmod +x ${HOME}/${VERSION}/${MAKE_TARGET}
    if [[ "${COMPONENT}" = "executor" ]]; then
        cd ${HOME}/${VERSION}/
        unzip -o ${MAKE_TARGET}
        mv ./saturn-executor-master-SNAPSHOT/* ./ 
        rm -fr saturn-executor-master-SNAPSHOT
    fi
    echo "install file end."
}

function createLaunchShell(){
    if [[ "${COMPONENT}" = "executor" ]]; then
echo -e '#!/bin/sh
. '${HOME}/${VERSION}'/bin/saturn-executor.sh $@'>/usr/local/bin/launch
    else
        echo -e '#!/bin/sh
cd '${HOME}/${VERSION}'
java ${JAVA_OPTS} -jar '${MAKE_TARGET}>/usr/local/bin/launch
    fi
    chmod +x /usr/local/bin/launch 
}

function installCentOSHandle(){
    prepareInstall
    download
    check
    install
    createLaunchShell
}

function installAlpineHandle(){
    prepareInstall
    download
    check
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
    clearSystem
}

function cleanAlpine(){
    clearSystem
    apk del maven
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
    if [ -z "$COMPONENT" ]; then
        echo 'component is empty!'
        exit 1005
    fi

    case "$COMPONENT" in
        "console")
            echo "make saturn-console solution."
            HOME=/opt/saturn-console
            SRC=${HOME}/${VERSION}/src
            MAKE_DIR=saturn-console
            MAKE_TARGET=saturn-console-master-SNAPSHOT-exec.jar
            ;;
        "executor")
            echo "make saturn-executor solution."
            HOME=/opt/saturn-executor
            SRC=${HOME}/${VERSION}/src
            MAKE_DIR=saturn-executor
            MAKE_TARGET=saturn-executor-master-SNAPSHOT-zip.zip
            ;;
        *)
            echo "system error,please enter!"
            exit 1005
            ;;
    esac

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
