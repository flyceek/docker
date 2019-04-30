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