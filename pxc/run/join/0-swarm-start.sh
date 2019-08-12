### slave & master ###
vi /lib/systemd/system/docker.service

systemctl disable firewalld.service
systemctl stop firewalld.service

[Service]
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock 

systemctl daemon-reload 
systemctl restart docker
systemctl status docker.service


### master ###
docker swarm init --force-new-cluster --advertise-addr 10.4.99.4
docker swarm join-token worker
docker swarm join-token manager

### slave ###
docker swarm join --token

docker swarm join --token SWMTKN-1-4ujrojw1y1o3xtn8ifca4ej41pm01f06vbxb7msykrwgnevm5l-apy7cuugz9h7dikcz7la7gb77 10.4.99.4:2377 --advertise-addr 10.28.19.196

docker swarm leave --force