docker network create --driver bridge pyspider


docker run -d --rm \
--name mongo_test1 \
-p 27017:27017 \
-v /var/mongo/data:/data/ \
-e MONGO_INITDB_ROOT_USERNAME=flyceek \
-e MONGO_INITDB_ROOT_PASSWORD='123321' \
mongo \
--auth


docker run -d --rm \
--name monto_express_test1 \
-p 3333:8081 \
--link mongo_test1:mongo \
-e ME_CONFIG_MONGODB_ADMINUSERNAME=flyceek \
-e ME_CONFIG_MONGODB_ADMINPASSWORD='123321' \
mongo-express


docker run -d --rm \
-p 5671:5671 \
-p 5672:5672 \
-p 15672:15672 \
-p 15671:15671 \
-p 25672:25672 \
--name rabbitmq_t1 \
--memory 256m \
--hostname flyceek-rabbit-1 \
-v /var/rabbitmq/data:/var/lib/rabbitmq \
-e RABBITMQ_DEFAULT_USER=flyceek \
-e RABBITMQ_DEFAULT_PASS=123321 \
-e RABBITMQ_VM_MEMORY_HIGH_WATERMARK=0.5 \
rabbitmq:3.7.8-management

docker run -d --rm \
--name pyspider_scheduler_test1 \
-p 23333:23333 \
binux/pyspider \
--taskdb "mongodb+taskdb://flyceek:123321@10.28.19.196:27017/taskdb?authSource=admin" \
--resultdb "mongodb+resultdb://flyceek:123321@10.28.19.196:27017/resultdb?authSource=admin" \
--projectdb "mongodb+projectdb://flyceek:123321@10.28.19.196:27017/projectdb?authSource=admin" \
--message-queue "amqp://flyceek:123321@10.28.19.196:5672/%2F" \
scheduler \
--inqueue-limit 10000 \
--delete-time 3600

mongo -u flyceek -p 123321 --authenticationDatabase admin
use admin
db.createUser({ user:'flyceek', pwd: '123321', roles: [ { role: "root",db: "admin" }]})
