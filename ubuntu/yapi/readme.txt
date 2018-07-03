docker-compose up -d


docker run -it --rm --name yapi-testA --link mongodb:mongodb -v /var/yapi/config.json:/opt/soft/yapi/config.json --net yapi_default yapi-test bash