1-init
docker swarm init

2-deploy
$ sudo docker stack deploy -c docker-compose.yml code-push-server

3-ls
$ sudo docker service ls
$ sudo docker service ps code-push-server_db
$ sudo docker service ps code-push-server_redis
$ sudo docker service ps code-push-server_server

4-exit
$ sudo docker stack rm code-push-server
$ sudo docker swarm leave --force