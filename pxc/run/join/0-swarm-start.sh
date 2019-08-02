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
docker swarm leave --force