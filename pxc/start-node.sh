CLUSTER_NAME=${CLUSTER_NAME:-Theistareykjarbunga}
ETCD_HOST=${ETCD_HOST:-10.20.2.4:2379}
NETWORK_NAME=${CLUSTER_NAME}_net

docker network create -d overlay $NETWORK_NAME

echo "Starting new node..."
docker run -d \
    --rm \
    -p 3306 \
    --net=$NETWORK_NAME \
    -e MYSQL_ROOT_PASSWORD=Theistareyk \
    -e DISCOVERY_SERVICE=$ETCD_HOST \
    -e CLUSTER_NAME=${CLUSTER_NAME} \
    -e XTRABACKUP_PASSWORD=Theistare \
    --name=pxc-node1 \
    percona/percona-xtradb-cluster
#--general-log=1 --general_log_file=/var/lib/mysql/general.log
echo "Started $(docker ps -l -q)"

# --wsrep_cluster_address="gcomm://$QCOMM"

------------------------------------------------------------------------------------------------------------------------------------
docker network rm pxc-net1
#docker network create -d overlay pxc-net1
docker network create -d overlay --attachable pxc-net1

docker run --rm \
-d \
-p 17331:3306 \
--name=pxc-node1 \
--net=pxc-net1 \
-e MYSQL_ROOT_PASSWORD=123321 \
-e DISCOVERY_SERVICE=10.4.99.4:2379 \
-e CLUSTER_NAME=pxc-cluster1 \
-e XTRABACKUP_PASSWORD=123321 \
percona/percona-xtradb-cluster

------------------------------------------------------------------------------------------------------------------------------------