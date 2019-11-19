#!/bin/sh
SYSTEM=$1
TYPE=$2
COMPONENT=$3
VERSION=$4

FILE_NAME=''
FILE_URL=''
MAKE_DIR=''
MAKE_TARGET=''

HOME=''
SRC=''


if [ -z "$VERSION" ]; then
    echo 'version param is empty!'
    exit 1001
fi

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
    cd ${SRC}
    local path=$(pwd)
    echo 'begin download in path :'${path}', url :'${FILE_URL}'.'
    git clone --depth=1 --single-branch --branch=master ${FILE_URL} ${SRC}
    echo 'end download in path :'${path}', url :'${FILE_URL}'.'
}

function prepareInstall(){
    mkdir -p ${SRC}
    cd ${HOME}
    local path=$(pwd)
    echo 'prepare in path :'${path}', url :'${FILE_URL}'.'
    
}

function install() {
    cd ${SRC}
    mvn clean package -Dmaven.javadoc.skip=true -Dmaven.test.skip=true
    if [ ! -f "${MAKE_DIR}/target/${MAKE_TARGET}" ]; then
        echo 'make target , file :'${MAKE_DIR}'/target/'${MAKE_TARGET}' not found!'
        exit 1010
    fi
    mv ${MAKE_DIR}/target/${MAKE_TARGET} ${HOME}/${VERSION}/
    chmod 777 ${HOME}/${VERSION}/${MAKE_TARGET}
    if [[ "${COMPONENT}" = "scheduler" ]]; then
        cd ${HOME}/${VERSION}/
        pwd
        ls -alsh
        tar -xvf ${MAKE_TARGET} -C ${HOME}/${VERSION} --strip-components=1
        rm -fr ${MAKE_TARGET}        
        chmod -R +x ./
    fi
    echo "install file end."
}

function createLaunchShell(){
    if [[ "${COMPONENT}" = "scheduler" ]]; then
        echo -e '#!/bin/sh
chronyd
cd '${HOME}/${VERSION}'/bin
sh start.sh $@'>/usr/local/bin/launch
    else
        echo -e '#!/bin/sh
chronyd
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
    if [ -z "$TYPE" ]; then
        echo 'type is empty!'
        exit 1005
    fi
    if [ -z "$COMPONENT" ]; then
        echo 'component is empty!'
        exit 1005
    fi

    case "$TYPE" in
        "cloud")
            echo "make cloud solution."            
            FILE_URL=https://github.com/elasticjob/elastic-job-cloud.git
            ;;
        "lite")
            echo "make lite solution."
            ;;
        *)
            echo "type error,please enter!"
            exit 1005
            ;;
    esac

    case "$COMPONENT" in
        "scheduler")
            echo "make scheduler solution."
            HOME=/opt/elastic-job-cloud/scheduler
            SRC=${HOME}/${VERSION}/src
            MAKE_DIR=elastic-job-cloud-scheduler
            MAKE_TARGET=elastic-job-cloud-scheduler-3.0.0.M1-SNAPSHOT.tar.gz
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
