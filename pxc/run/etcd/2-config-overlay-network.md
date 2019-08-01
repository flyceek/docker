#### method0 ####
### node0 ###
sudo service docker stop
sudo /usr/bin/docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://10.4.99.4:2379 --cluster-advertise=10.4.99.4:2375
sudo /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://10.4.99.4:2379 --cluster-advertise=10.4.99.4:2375

sudo service docker stop
sudo /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://10.4.99.4:2379 --cluster-advertise=10.4.99.4:2375

### node1 ###
sudo service docker stop
sudo /usr/bin/docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://10.28.19.196:2379 --cluster-advertise=10.28.19.196:2375


#### method1 ####
### node0 ###
vi /lib/systemd/system/docker.service

[Service]
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://10.4.10.105:2379 --cluster-advertise=10.4.99.4:2375

systemctl daemon-reload 
systemctl restart docker
systemctl status docker.service

### node1 ###
vi /lib/systemd/system/docker.service

[Service]
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://10.4.10.105:2379 --cluster-advertise=10.28.19.196:2375

systemctl daemon-reload 
systemctl restart docker
systemctl status docker.service

