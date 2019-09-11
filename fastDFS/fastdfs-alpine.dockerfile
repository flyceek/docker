FROM alpine

ARG WORK_HOME=/opt

RUN apk update \
    && apk add --no-cache --virtual .build-deps bash gcc libc-dev make openssl-dev pcre-dev zlib-dev linux-headers curl wget gnupg libxslt-dev gd-dev geoip-dev \
    && mkdir -p ${WORK_HOME} \
    && cd ${WORK_HOME} \
    && curl -fSL https://github.com/happyfish100/libfastcommon/archive/master.tar.gz -o fastcommon.tar.gz \
    && curl -fSL https://github.com/happyfish100/fastdfs/archive/master.tar.gz -o fastfs.tar.gz \
    && curl -fSL https://github.com/happyfish100/fastdfs-nginx-module/archive/master.tar.gz -o nginx-module.tar.gz \
    && tar zxf fastcommon.tar.gz \
    && tar zxf fastfs.tar.gz \
    && tar zxf nginx-module.tar.gz \
    && cd ${WORK_HOME}/libfastcommon-master/ \
    && ./make.sh \
    && ./make.sh install \
    && cd ${HOME}/fastdfs-master/ \
    && ./make.sh \
    && ./make.sh install \
    && cd /etc/fdfs/ \
    && cp storage.conf.sample storage.conf \
    && cp tracker.conf.sample tracker.conf \
    && cp client.conf.sample client.conf \
    && sed -i "s|/home/yuqing/fastdfs|/var/local/fdfs/tracker|g" /etc/fdfs/tracker.conf \
    && sed -i "s|/home/yuqing/fastdfs|/var/local/fdfs/storage|g" /etc/fdfs/storage.conf \
    && sed -i "s|/home/yuqing/fastdfs|/var/local/fdfs/storage|g" /etc/fdfs/client.conf \
    && cd ${WORK_HOME} \
    && curl -fSL http://nginx.org/download/nginx-1.15.3.tar.gz -o nginx-1.17.3.tar.gz \
    && tar zxf nginx-1.15.3.tar.gz \
    && chmod u+x ${WORK_HOME}/fastdfs-nginx-module-master/src/config \
    && cd nginx-1.17.3 \
    && ./configure --add-module=${WORK_HOME}/fastdfs-nginx-module-master/src \
    && make \
    && make install \
    && cp ${WORK_HOME}/fastdfs-nginx-module-master/src/mod_fastdfs.conf /etc/fdfs/ \
    && sed -i "s|^store_path0.*$|store_path0=/var/local/fdfs/storage|g" /etc/fdfs/mod_fastdfs.conf \
    && sed -i "s|^url_have_group_name =.*$|url_have_group_name = true|g" /etc/fdfs/mod_fastdfs.conf \
    && cd ${WORK_HOME}/fastdfs-master/conf/ \
    && cp http.conf mime.types anti-steal.jpg /etc/fdfs/ \
    && echo -e "\
events {\n\
worker_connections  1024;\n\
}\n\
http {\n\
include       mime.types;\n\
default_type  application/octet-stream;\n\
server {\n\
    listen 8080;\n\
    server_name localhost;\n\
    location ~ /group[0-9]/M00 {\n\
        ngx_fastdfs_module;\n\
    }\n\
    }\n\
}" >/usr/local/nginx/conf/nginx.conf \
    && rm -rf ${WORK_HOME}/* \
    && apk del .build-deps gcc libc-dev make openssl-dev linux-headers curl gnupg libxslt-dev gd-dev geoip-dev \
    && apk add bash pcre-dev zlib-dev \
    && echo -e "\
mkdir -p /var/local/fdfs/storage/data /var/local/fdfs/tracker; \n\
ln -s /var/local/fdfs/storage/data/ /var/local/fdfs/storage/data/M00; \n\n\
sed -i \"s/listen\ .*$/listen\ \$WEB_PORT;/g\" /usr/local/nginx/conf/nginx.conf; \n\
sed -i \"s/http.server_port=.*$/http.server_port=\$WEB_PORT/g\" /etc/fdfs/storage.conf; \n\n\
if [ \"\$IP\" = \"\" ]; then \n\
    IP=`ifconfig eth0 | grep inet | awk '{print \$2}'| awk -F: '{print \$2}'`; \n\
fi \n\
sed -i \"s/^tracker_server=.*$/tracker_server=\$IP:\$FDFS_PORT/g\" /etc/fdfs/client.conf; \n\
sed -i \"s/^tracker_server=.*$/tracker_server=\$IP:\$FDFS_PORT/g\" /etc/fdfs/storage.conf; \n\
sed -i \"s/^tracker_server=.*$/tracker_server=\$IP:\$FDFS_PORT/g\" /etc/fdfs/mod_fastdfs.conf; \n\n\
/etc/init.d/fdfs_trackerd start; \n\
/etc/init.d/fdfs_storaged start; \n\
/usr/local/nginx/sbin/nginx; \n\
tail -f /usr/local/nginx/logs/access.log \
">/start.sh \
    && chmod u+x /start.sh

ENV WEB_PORT 8080
ENV FDFS_PORT 22122

ENTRYPOINT ["/bin/bash","/start.sh"]