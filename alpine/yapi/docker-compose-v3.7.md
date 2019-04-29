init:
docker swarm init

deploy:
docker stack deploy -c docker-compose-v3.7.yml yapi-web

destroy:
docker stack rm yapi-web