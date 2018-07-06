docker-compose up -d


docker run -it --rm --name yapi-testA --link yapi-mongodb:mongodb --add-host=mongodb:172.21.0.3 -v /var/yapi/config.json:/opt/soft/yapi/yapi-v1.3.17/config.json -v /var/yapi/log:/opt/soft/yapi/yapi-v1.3.17/log --net ubuntu_default yapi-test bash