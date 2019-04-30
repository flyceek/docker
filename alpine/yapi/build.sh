#!/bin/sh
YAPI_VERSION=1.7.0
if [ -n "$1" ]; then
    echo 'input version is :'$1
    YAPI_VERSION=$1
fi

YAPI_FILENAME=v${YAPI_VERSION}.tar.gz
YAPI_FILE_EXTRACT_DIR=yapi-v${YAPI_VERSION}
YAPI_FILEURL=https://github.com/YMFE/yapi/archive/${YAPI_FILENAME}

YAPI_WORK_HOME=/opt/yapi
YAPI_SRC_PATH=${YAPI_WORK_HOME}/${YAPI_FILE_EXTRACT_DIR}

YAPI_USER=yapi
YAPI_GROUP=yapi

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

echo '#!/bin/sh\ncd ${YAPI_SRC_PATH}\nnpm run install-server\npm2 start server/app.js\npm2 logs'>/usr/local/bin/yapi-initdb-start
echo '#!/bin/sh\ncd ${YAPI_SRC_PATH}\npm2 start server/app.js\npm2 logs'>/usr/local/bin/yapi-initdb-start
chmod +x /usr/local/bin/yapi-initdb-start 
chmod +x /usr/local/bin/yapi-start
chown -R ${YAPI_USER}:${YAPI_GROUP} ${YAPI_WORK_HOME}
echo "root:123321" | chpasswd
