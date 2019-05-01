deploy
$ sudo docker stack deploy -c docker-compose.yml code-push-server

ls
$ sudo docker service ls
$ sudo docker service ps code-push-server_db
$ sudo docker service ps code-push-server_redis
$ sudo docker service ps code-push-server_server

exit
$ sudo docker stack rm code-push-server
$ sudo docker swarm leave --force