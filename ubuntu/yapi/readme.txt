docker-compose up -d


docker run -it --rm --name yapi-testA --link yapi_yapi-mongodb_1:mongodb --add-host=mongodb:172.20.0.3 -v /var/yapi/config.json:/opt/soft/yapi/config.json -v /var/yapi/log:/opt/soft/yapi/yapi-v1.3.17/log --net yapi_default yapi-test bash