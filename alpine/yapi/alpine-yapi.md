docker run -itd \
--rm \
--name yapi-web-1 \
--link yapi_yapi-mongodb_1:mongodb \
--add-host=mongodb:172.18.0.2 \
--add-host=ldap.centaline.com.cn:10.4.19.13 \
-p 3003:3000 \
-v /var/yapi/config.json:/opt/soft/yapi/config.json \
--net yapi_default \
flyceek/ubuntu-yapi yapi-start