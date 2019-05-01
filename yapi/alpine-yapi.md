mkdir -p /var/yapi/mongo/data/db
touch /var/yapi/config.json
chmod -R 777 /var/yapi
docker-compose up -d


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


docker stack deploy:
    init:
    docker swarm init

    deploy:
    docker stack deploy -c docker-compose-v3.7.yml yapi-web

    destroy:
    docker stack rm yapi-web

docker compose:
    up:
    docker-compose -f compose.yml up -d
    down:
    docker-compose -f compose.yml down
    rm:
    docker-compose -f compose.yml rm