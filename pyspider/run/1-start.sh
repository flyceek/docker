docker network rm pyspider
docker network create --driver bridge pyspider

docker run -d --rm \
--name mongo_test1 \
-p 27017:27017 \
-v /var/mongo/data:/data/ \
-e MONGO_INITDB_ROOT_USERNAME=flyceek \
-e MONGO_INITDB_ROOT_PASSWORD='123321' \
mongo \
--auth