### node0 ###
docker network rm pxc-net0
docker volume rm pxc-v0
docker network create -d overlay --attachable pxc-net0
# docker network create -d bridge pxc-net0
docker volume create pxc-v0

docker run -d \
--rm \
-p 17331:3306 \
--name=pxc-node0 \
-v pxc-v0:/var/lib/mysql \
--net=pxc-net0 \
-e MYSQL_ROOT_PASSWORD=123321 \
-e DISCOVERY_SERVICE=10.4.99.4:2379 \
-e CLUSTER_NAME=pxc-cluster0 \
-e XTRABACKUP_PASSWORD=123321 \
percona/percona-xtradb-cluster

docker logs -f pxc-node0

docker run --rm \
-p 4567:4567 \
-p 17331:3306 \
-e MYSQL_ROOT_PASSWORD=123321 \
-e CLUSTER_NAME=pxc-cluster0 \
-e XTRABACKUP_PASSWORD=123321 \
-e CLUSTER_JOIN=10.4.99.4 \
-v pxc_v2:/var/lib/mysql \
-v pxc_backup2:/data \
--privileged \
--name=pxc_node2 \
--net=pxc_net2 \
percona/percona-xtradb-cluster

# my.cnf:/etc/my.cnf

### node1 ###
docker network rm pxc-net1
docker volume rm pxc-v1
docker network create -d overlay --attachable pxc-net1
# docker network create -d bridge pxc-net1
docker volume create pxc-v1

docker run -d \
--rm \
-p 17331:3306 \
--name=pxc-node1 \
-v pxc-v1:/var/lib/mysql \
--net=pxc-net1 \
-e MYSQL_ROOT_PASSWORD=123321 \
-e DISCOVERY_SERVICE=10.4.99.4:2379 \
-e CLUSTER_NAME=pxc-cluster0 \
-e XTRABACKUP_PASSWORD=123321 \
percona/percona-xtradb-cluster

### test ###
docker run -it \
--rm \
--name=pxc-node-test \
percona/percona-xtradb-cluster \
sh