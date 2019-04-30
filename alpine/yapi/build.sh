#!/bin/sh
YAPI_WORK_HOME=/opt/yapi
YAPI_VERSION=$1
YAPI_PATH=''

YAPI_USER=$2

function installSystemDependencies(){
    apk add --update --no-cache --virtual=.yapi-dependencies git wget python tar xz make
}

function setNpm(){
    npm config set registry https://registry.npm.taobao.org
}

function installNpmDependencies() {
    npm i -g pm2@latest --no-optional
}

function createUserGroup(){
    local yuser=$1
    if [ -z "$yuser" ]; then
        echo 'yapi user is empty!'
        exit 1
    fi
    local ygroup=yuser
    addgroup -g 1090 ${ygroup}
    adduser -h /home/${yuser} -u 1090 -G ${ygroup} -s /bin/bash -D ${yuser}
}

function createYapiStartShell(){
    if [ -d "$YAPI_PATH" ]; then
        echo 'yapi source path is not found !'
        exit 1
    fi

    echo -e '#!/bin/sh
cd '${YAPI_PATH}'
npm run install-server
pm2 start server/app.js
pm2 logs'>/usr/local/bin/yapi-initdb-start

    echo -e '#!/bin/sh
cd '${YAPI_PATH}'
pm2 start server/app.js
pm2 logs'>/usr/local/bin/yapi-initdb-start

    chmod +x /usr/local/bin/yapi-initdb-start 
    chmod +x /usr/local/bin/yapi-start
}

function installYapiByReleaseCode(){
    local fileName=v${YAPI_VERSION}.tar.gz
    local fileUrl=https://github.com/YMFE/yapi/archive/${fileName}
    local srcPath=${YAPI_WORK_HOME}/yapi-v${YAPI_VERSION}
    
    mkdir -p ${srcPath}
    cd ${YAPI_WORK_HOME}
    wget ${fileUrl}
    if [ !-f "$fileName" ] then
        echo 'down file '$fileName' is error !'
        exit 1
    fi
    tar -xzvf ${fileName} -C ${srcPath} --strip-components 1
    rm ${fileName}
    cd ${srcPath}
    npm install --production
    YAPI_PATH=${srcPath}
    if [ $? -ne 0 ]; then
        echo 'something wrong happened !'
        exit 1
    fi
}

function installYapiBySourceCode(){
    local gitUrl=https://github.com/YMFE/yapi.git
    local srcPath=${YAPI_WORK_HOME}/yapi-source-master
    mkdir -p ${srcPath}
    cd ${YAPI_WORK_HOME}
    git clone --depth=1 --single-branch --branch=master ${gitUrl} ${srcPath}
    cd ${srcPath}
    npm install --production
    YAPI_PATH=${srcPath}
    if [ $? -ne 0 ]; then
        echo 'something wrong happened !'
        exit 1
    fi
}

function installYapi(){
    if [ -n "$YAPI_VERSION" ]; then
        echo 'input version is :'$YAPI_VERSION' .'
        echo 'install yapi use release code!'
        installYapiByReleaseCode
    else
        echo 'install yapi use source code!'
        installYapiBySourceCode
    fi
}

function setSystem(){
    echo "root:123321" | chpasswd
    chown -R ${YAPI_USER}:${YAPI_USER} ${YAPI_WORK_HOME}
}


installSystemDependencies
setNpm
installNpmDependencies
createUserGroup ${YAPI_USER}
installYapi
createYapiStartShell
setSystem