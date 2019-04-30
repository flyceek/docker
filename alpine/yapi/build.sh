#!/bin/sh
YAPI_VERSION=1.7.0
if [ -n "$1" ]; then
    echo 'input version is :'$1
    YAPI_VERSION=$1
fi

YAPI_USER=yapi
if [ -n "$2" ]; then
    echo 'input yapi user is :'$2
    YAPI_USER=2
fi
YAPI_GROUP=${YAPI_USER}

YAPI_FILENAME=v${YAPI_VERSION}.tar.gz
YAPI_FILE_EXTRACT_DIR=yapi-v${YAPI_VERSION}
YAPI_FILEURL=https://github.com/YMFE/yapi/archive/${YAPI_FILENAME}

YAPI_WORK_HOME=/opt/yapi
YAPI_SRC_PATH=${YAPI_WORK_HOME}/${YAPI_FILE_EXTRACT_DIR}

apk add --update --no-cache --virtual=.yapi-dependencies git wget python tar xz make

npm config set registry https://registry.npm.taobao.org
npm i -g pm2@latest --no-optional

addgroup -g 1090 ${YAPI_GROUP}
adduser -h /home/${YAPI_USER} -u 1090 -G ${YAPI_GROUP} -s /bin/bash -D ${YAPI_USER}

mkdir -p ${YAPI_SRC_PATH}
cd ${YAPI_WORK_HOME}
wget ${YAPI_FILEURL}
tar -xzvf ${YAPI_FILENAME} -C ${YAPI_FILE_EXTRACT_DIR} --strip-components 1
rm ${YAPI_FILENAME}
cd ${YAPI_SRC_PATH}
npm install --production

echo -e '#!/bin/sh
cd '${YAPI_SRC_PATH}'
npm run install-server
pm2 start server/app.js
pm2 logs'>/usr/local/bin/yapi-initdb-start

echo -e '#!/bin/sh
cd '${YAPI_SRC_PATH}'
pm2 start server/app.js
pm2 logs'>/usr/local/bin/yapi-initdb-start

chmod +x /usr/local/bin/yapi-initdb-start 
chmod +x /usr/local/bin/yapi-start
chown -R ${YAPI_USER}:${YAPI_GROUP} ${YAPI_WORK_HOME}
echo "root:123321" | chpasswd
