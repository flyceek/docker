############### overylay network ###############
### node0 ###
docker network rm pxc-net0
docker network create -d overlay --attachable pxc-net0
docker network inspect pxc-node0
docker volume rm pxc-v0
docker volume create pxc-v0

docker volume rm pxc-backup0
docker volume create pxc-backup0

# docker network create -d overlay \
# --subnet=10.10.0.0/16 \
# --gateway=10.10.0.254 \
# --attachable=true \
# pxc-net0

# docker network create -d bridge pxc-net0


docker run -d \
--rm \
-p 4567:4567 \
-p 17331:3306 \
--name=pxc-node0 \
-v pxc-v0:/var/lib/mysql \
-v pxc-backup0:/data \ 
--net=pxc-net0 \
-e MYSQL_ROOT_PASSWORD=123321 \
-e CLUSTER_NAME=pxc-cluster0 \
-e XTRABACKUP_PASSWORD=123321 \
--privileged \
--ip 10.0.0.101 \
percona/percona-xtradb-cluster

docker logs -f pxc-node0

# docker service create \
# --replicas 1 \
# --network pxc-net0 \
# -p 17331:3306 \
# --name pxc-node0 \
# --mount type=volume,source=pxc-v0,destination=/var/lib/mysql \
# -e MYSQL_ROOT_PASSWORD=123321 \
# -e CLUSTER_NAME=pxc-cluster0 \
# -e XTRABACKUP_PASSWORD=123321 \
# percona/percona-xtradb-cluster

# my.cnf:/etc/my.cnf

### node1 ###
docker volume rm pxc-v1
docker volume create pxc-v1

docker volume rm pxc-backup1
docker volume create pxc-backup1
# docker network rm pxc-net1
# docker network create -d overlay --attachable pxc-net1
# docker network create -d bridge pxc-net1


docker run -d \
--rm \
-p 4567:4567 \
-p 17331:3306 \
--name=pxc-node1 \
-v pxc-v1:/var/lib/mysql \
-v pxc-backup1:/data \
--net=pxc-net0 \
-e MYSQL_ROOT_PASSWORD=123321 \
-e CLUSTER_JOIN=10.0.0.101 \
-e CLUSTER_NAME=pxc-cluster0 \
-e XTRABACKUP_PASSWORD=123321 \
--privileged \
--ip 10.0.0.102 \
percona/percona-xtradb-cluster

docker logs -f pxc-node1

### test ###
docker run -it \
--rm \
--name=pxc-node-test \
percona/percona-xtradb-cluster \
sh


############### host network ###############
### node0 ###
docker volume rm pxc-v0
docker volume create pxc-v0

docker run -d \
--rm \
-p 4567:4567 \
-p 17331:3306 \
--name=pxc-node0 \
-v pxc-v0:/var/lib/mysql \
--net=host \
-e MYSQL_ROOT_PASSWORD=123321 \
-e CLUSTER_NAME=pxc-cluster0 \
-e XTRABACKUP_PASSWORD=123321 \
--privileged \
percona/percona-xtradb-cluster

docker logs -f pxc-node0

### node1 ###
docker volume rm pxc-v1
docker volume create pxc-v1

docker run -d \
--rm \
-p 4567:4567 \
-p 17331:3306 \
--name=pxc-node1 \
-v pxc-v1:/var/lib/mysql \
--net=host \
-e MYSQL_ROOT_PASSWORD=123321 \
-e CLUSTER_JOIN=10.4.99.4 \
-e CLUSTER_NAME=pxc-cluster0 \
-e XTRABACKUP_PASSWORD=123321 \
--privileged \
percona/percona-xtradb-cluster

docker logs -f pxc-node1

############### stand alone ###############
### node0 ###
docker volume rm pxc-v0
docker volume create pxc-v0
docker network rm pxc-net0
docker network create -d bridge --subnet=178.0.0.0/24 pxc-net0

docker run -d \
--rm \
-p 17331:3306 \
--name=pxc-node0 \
-v pxc-v0:/var/lib/mysql \
--net=pxc-net0 \
-e MYSQL_ROOT_PASSWORD=123321 \
-e CLUSTER_NAME=pxc-cluster0 \
-e XTRABACKUP_PASSWORD=123321 \
--privileged \
--ip 178.0.0.5 \
percona/percona-xtradb-cluster

docker logs -f pxc-node0

### node1 ###
docker volume rm pxc-v1
docker volume create pxc-v1

docker run -d \
--rm \
-p 17332:3306 \
--name=pxc-node1 \
-v pxc-v1:/var/lib/mysql \
--net=pxc-net0 \
-e MYSQL_ROOT_PASSWORD=123321 \
-e CLUSTER_JOIN=178.0.0.5 \
-e CLUSTER_NAME=pxc-cluster0 \
-e XTRABACKUP_PASSWORD=123321 \
--privileged \
--ip 178.0.0.6 \
percona/percona-xtradb-cluster

docker logs -f pxc-node1