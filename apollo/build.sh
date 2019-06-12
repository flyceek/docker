#!/bin/sh
APOLLO_WORK_HOME=/opt/apollo
APOLLO_VERSION=$1
APOLLO_PATH=''

APOLLO_USER=$2
APOLLO_COMP=$3

function installSystemDependencies(){
    echo "http://mirrors.aliyun.com/alpine/v3.8/main" > /etc/apk/repositories \
    && echo "http://mirrors.aliyun.com/alpine/v3.8/community" >> /etc/apk/repositories \
    && apk update upgrade \
    && apk add --no-cache --virtual=.apollo-dependencies procps unzip wget curl bash tar tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone
}

function createUserGroup(){
    if [ -z "$1" ]; then
        echo 'apollo user is empty!'
        exit 1
    fi
    local yuser=$1
    local yuserId=1090
    local ygroup=$yuser
    local ygroupId=1090
    echo 'begin crate user :'$yuser ', group :'$ygroup'.'
    addgroup -g ${ygroupId} ${ygroup}
    adduser -h /home/${yuser} -u ${yuserId} -G ${ygroup} -s /bin/bash -D ${yuser}
}

function createApolloStartShell(){
    if [ ! -d "$APOLLO_PATH" ]; then
        echo 'apollo source path : '$APOLLO_PATH' is not found !'
        exit 1
    fi

    echo -e '#!/bin/bash
cd '${APOLLO_WORK_HOME}/apollo-${APOLLO_COMP}-v${APOLLO_VERSION}'
bash scripts/startup.sh
'>/usr/local/bin/apollo-${APOLLO_COMP}-start

    chmod +x /usr/local/bin/apollo-${APOLLO_COMP}-start 
}

function installApolloByReleaseCode(){
    local fileName=apollo-${APOLLO_COMP}-${APOLLO_VERSION}-github.zip
    local fileUrl=https://github.com/ctripcorp/apollo/releases/download/v${APOLLO_VERSION}/${fileName}
    local srcPath=${APOLLO_WORK_HOME}/apollo-${APOLLO_COMP}-v${APOLLO_VERSION}
    echo 'begin download file:'${fileUrl}
    mkdir -p ${srcPath}
    cd ${APOLLO_WORK_HOME}
    wget ${fileUrl}
    if [ ! -f "$fileName" ]; then
        echo 'down file '$fileName' is error !'
        exit 1
    fi
    unzip ${fileName} -d ${srcPath} \
    && rm -rf ${fileName} \
    && sed -i '$d' ${srcPath}/scripts/startup.sh \
    && echo "tail -f /dev/null" >> ${srcPath}/scripts/startup.sh
    if [ $? -ne 0 ]; then
        echo 'something wrong happened !'
        exit 1
    fi
    APOLLO_PATH=${srcPath}
}

function installApolloBySourceCode(){
    echo 'install apollo use source code not supported!!!'
    exit 991
}

function installApollo(){
    if [ -n "$APOLLO_VERSION" ]; then
        echo 'input version is :'$APOLLO_VERSION' .'
        echo 'install apollo use release code!'
        installApolloByReleaseCode
    else
        echo 'install apollo use source code!'
        installApolloBySourceCode
    fi
    createApolloStartShell
}

function setSystem(){
    echo "root:123321" | chpasswd
    chown -R ${APOLLO_USER}:${APOLLO_USER} /opt
}

function clearSystem(){
    rm /build.sh
}

function install(){
    installSystemDependencies
    createUserGroup ${APOLLO_USER}
    installApollo
    setSystem
    clearSystem
}

function installAdminservice(){
    install
}

function installConfigservice(){
    install
}

function installPortal(){
    install
    local portalEnvFile=${APOLLO_WORK_HOME}/apollo-${APOLLO_COMP}-v${APOLLO_VERSION}/config/apollo-env.properties
    if [ ! -f "$portalEnvFile" ]; then
        echo 'apollo portal env file '$fileName' is not found !'
        exit 10092
    fi
    echo -e 'local.meta=${local_meta}
dev.meta=${dev_meta}
fat.meta=${fat_meta}
uat.meta=${uat_meta}
lpt.meta=${lpt_meta}
pro.meta=${pro_meta}'>${portalEnvFile}
}

function doAction(){
    if [ -z "$APOLLO_COMP" ]; then
        echo 'apollo component is empty!'
        exit 119
    fi
    case "$APOLLO_COMP" in
        "adminservice")
            echo "begin install apollo adminservice."
            installAdminservice
            ;;
        "configservice")
            echo "begin install apollo configservice."
            installConfigservice
            ;;
        "portal")
            echo "begin install apollo portal."
            installPortal
            ;;
        *)
            echo "component error,please enter!"
            exit 1006
            ;;
    esac

}

doAction