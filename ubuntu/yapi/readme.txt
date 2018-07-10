mkdir -p /var/yapi/mongo/data/db
touch /var/yapi/config.json
chmod -R 777 /var/yapi
docker-compose up -d
