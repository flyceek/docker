#!/bin/sh
WORK_HOME=/opt/code-push-server
VERSION=$1
APP_PATH=''

USER=$2

function installSystemDependencies(){
    apk add --update --no-cache --virtual=.yapi-dependencies git wget
}

function setNpm(){
    npm config set registry https://registry.npm.taobao.org
}

function installNpmDependencies() {
    npm i -g pm2@latest --no-optional
}

function createUserGroup(){
    if [ -z "$1" ]; then
        echo 'yapi user is empty!'
        exit 1
    fi
    local user=$1
    local userId=1090
    local group=$user
    local groupId=1090
    echo 'begin crate user :'$user ', group :'$group'.'
    addgroup -g ${groupId} ${group}
    adduser -h /home/${user} -u ${userId} -G ${group} -s /bin/bash -D ${user}
}

function installCodePushServerByReleaseCode(){
    local fileName=v${VERSION}.tar.gz
    local fileUrl=https://github.com/lisong/code-push-server/archive/${fileName}
    local srcPath=${WORK_HOME}/code-push-server-v${VERSION}
    
    mkdir -p ${srcPath}
    cd ${WORK_HOME}
    wget ${fileUrl}
    if [ ! -f "$fileName" ]; then
        echo 'down file '$fileName' is error !'
        exit 1
    fi
    tar -xzvf ${fileName} -C ${srcPath} --strip-components 1
    rm ${fileName}
    cd ${srcPath}
    echo 'begin npm install in :'${srcPath}' .'
    npm install --production
    APP_PATH=${srcPath}
    if [ $? -ne 0 ]; then
        echo 'something wrong happened !'
        exit 1
    fi
}

function installCodePushServerBySourceCode(){
    local gitUrl=https://github.com/lisong/code-push-server.git
    local srcPath=${WORK_HOME}/code-push-server-source-master
    mkdir -p ${srcPath}
    cd ${WORK_HOME}
    git clone --depth=1 --single-branch --branch=master ${gitUrl} ${srcPath}
    cd ${srcPath}
    echo 'begin npm install in :'${srcPath}' .'
    npm install --production
    APP_PATH=${srcPath}
    if [ $? -ne 0 ]; then
        echo 'something wrong happened !'
        exit 1
    fi
}

function installCodePushServer(){
    if [ -n "${VERSION}" ]; then
        echo 'input version is :'${VERSION}' .'
        echo 'install CodePushServer use release code!'
        installCodePushServerByReleaseCode
    else
        echo 'install CodePushServer use source code!'
        installCodePushServerBySourceCode
    fi
}

function createCodePushServerStartShell(){
    if [ ! -d "${APP_PATH}" ]; then
        echo 'app source path : '${APP_PATH}' is not found !'
        exit 1
    fi

    echo -e '#!/bin/sh
cd '${APP_PATH}'
pm2 start app.js
pm2 logs'>/usr/local/bin/code-push-server-start

    chmod +x /usr/local/bin/code-push-server-start
}

function setSystem(){
    echo "root:123321" | chpasswd
    chown -R ${USER}:${USER} ${WORK_HOME}
}

function clearSystem(){
    rm /build.sh
}

installSystemDependencies
setNpm
installNpmDependencies
createUserGroup ${YAPI_USER}
installCodePushServer
createCodePushServerStartShell
setSystem
clearSystem