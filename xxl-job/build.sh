#!/bin/sh
SYSTEM=$1
VERSION=$2

FILE_NAME=${VERSION}.tar.gz
FILE_URL=https://github.com/xuxueli/xxl-job/archive/${FILE_NAME}

HOME=/opt/xxl-job
SRC=${HOME}/${VERSION}/src


if [ -z "$VERSION" ]; then
    echo 'version param is empty!'
    exit 1001
fi

function installCentaOSDependencies(){
    yum update -y
    yum install -y tar.x86_64 wget
}

function installAlpineDependencies(){
    apk --update add --no-cache --virtual=.build-dependencies wget maven
}

function settingUpCentaOS(){
    installCentaOSDependencies
}

function settingUpAlpine(){
    installAlpineDependencies
}

function settingUpSystemUser(){
    echo "root:123321" | chpasswd
}

function downloadFromCentOS(){
    curl -o ${FILE_NAME} -C ${SRC} ${FILE_URL} 
}

function downloadFromAlpine(){
    cd ${HOME}
    wget -O ${FILE_NAME} -C ${SRC} ${FILE_URL}
}

function prepareInstall(){
    mkdir -p ${SRC}
    cd ${HOME}
    local path=$(pwd)
    echo 'begin download in path :'${path}', url :'${FILE_URL}'.'
}

function checkFile(){
    if [ ! -f "${FILE_NAME}" ]; then
        echo 'file :'${FILE_NAME}' not found!'
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

function store(){
    cd ${HOME}
    if [ ! -f "${FILE_NAME}" ]; then
        echo 'file :'${FILE_NAME}' not found!'
        exit 1010
    fi
    tar -xvf ${FILE_NAME} -C ${HOME} --strip-components=1
    if [ $? -ne 0 ]; then
        echo 'something wrong happened !'
        exit 1003
    fi
    rm -fr ${FILE_NAME}
}

function install() {
    cd ${HOME} \
    && tar -xvf ${FILE_NAME} -C ${SRC} --strip-components=1 \
    && cd ${SRC}/xxl-job-admin \
    && mvn clean package -Dmaven.test.skip=true
    && mv target/xxl-job-admin-${VERSION}.jar ${HOME}/${VERSION}/xxl-job-admin-${VERSION}.jar \
    && chmod +x ${HOME}/${VERSION}/xxl-job-admin-${VERSION}.jar \
    && echo "install file end."
}

function createlaunchShell(){
    if [ ! -d "$YAPI_PATH" ]; then
        echo 'yapi source path : '$YAPI_PATH' is not found !'
        exit 1
    fi

    echo -e '#!/bin/sh
cd '${HOME}/${VERSION}'
java -jar xxl-job-admin-'${VERSION}'.jar'>/usr/local/bin/launch

    chmod +x /usr/local/bin/launch 
}

function installCentOSHandle(){
    prepareInstall
    downloadFromCentOS
    install
    check
    store
}

function installAlpineHandle(){
    prepareInstall
    downloadFromAlpine
    install
    check
    store
}

function settingUpCentOSFile(){
    
}

function settingUpAlpineFile(){
    
}

function clearSystem(){
    rm -fr ${SRC} \
    && rm -fr ~/.m2/ \
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
    installAlpineHandle
    settingUpAlpine
    settingUpAlpineFile
    cleanAlpine
    settingUpSystemUser
}

function installFromCentaOS(){
    installCentOSHandle
    settingUpCentOS
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
            installFromCentaOS
            ;;
        *)
            echo "system error,please enter!"
            exit 1005
            ;;
    esac
}

doAction
