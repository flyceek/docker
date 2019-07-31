ETCD_HOST=${ETCD_HOST:-10.20.2.4:2379}
docker run -d -v /usr/share/ca-certificates/:/etc/ssl/certs -p 4001:4001 -p 2380:2380 -p 2379:2379 \
 --name etcd quay.io/coreos/etcd \
 -name etcd0 \
 -advertise-client-urls http://${ETCD_HOST}:2379,http://${ETCD_HOST}:4001 \
 -listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
 -initial-advertise-peer-urls http://${ETCD_HOST}:2380 \
 -listen-peer-urls http://0.0.0.0:2380 \
 -initial-cluster-token etcd-cluster-1 \
 -initial-cluster etcd0=http://${ETCD_HOST}:2380 \
 -initial-cluster-state new

### stand-alone ###
rm -rf /tmp/etcd-data.tmp 
mkdir -p /tmp/etcd-data.tmp

docker run \
-d \
--rm \
-p 2379:2379 \
-p 2380:2380 \
--mount type=bind,source=/tmp/etcd-data.tmp,destination=/etcd-data \
--name etcd-node0 \
flyceek/etcd \
/usr/local/bin/etcd \
--name etcd-node0 \
--data-dir /etcd-data \
--listen-client-urls http://0.0.0.0:2379 \
--advertise-client-urls http://10.4.99.4:2379 \
--listen-peer-urls http://0.0.0.0:2380 \
--initial-advertise-peer-urls http://10.4.99.4:2380 \
--initial-cluster "etcd-node0=http://10.4.99.4:2380" \
--initial-cluster-token tkn \
--initial-cluster-state new


### Cluster ###
#node0
rm -rf /tmp/etcd-data.tmp 
mkdir -p /tmp/etcd-data.tmp

docker run \
-d \
--rm \
-p 2379:2379 \
-p 2380:2380 \
--mount type=bind,source=/tmp/etcd-data.tmp,destination=/etcd-data \
--name etcd-node0 \
flyceek/etcd \
/usr/local/bin/etcd \
--name etcd-node0 \
--data-dir /etcd-data \
--listen-client-urls http://0.0.0.0:2379 \
--advertise-client-urls http://10.4.99.4:2379 \
--listen-peer-urls http://0.0.0.0:2380 \
--initial-advertise-peer-urls http://10.4.99.4:2380 \
--initial-cluster "etcd-node0=http://10.4.99.4:2380,etcd-node1=http://10.28.19.196:2380" \
--initial-cluster-token etcd-cluster \
--initial-cluster-state new

#node1
rm -rf /tmp/etcd-data.tmp 
mkdir -p /tmp/etcd-data.tmp

docker run \
-d \
--rm \
-p 2379:2379 \
-p 2380:2380 \
--mount type=bind,source=/tmp/etcd-data.tmp,destination=/etcd-data \
--name etcd-node1 \
flyceek/etcd \
/usr/local/bin/etcd \
--name etcd-node1 \
--data-dir /etcd-data \
--listen-client-urls http://0.0.0.0:2379 \
--advertise-client-urls http://10.28.19.196:2379 \
--listen-peer-urls http://0.0.0.0:2380 \
--initial-advertise-peer-urls http://10.28.19.196:2380 \
--initial-cluster "etcd-node0=http://10.4.99.4:2380,etcd-node1=http://10.28.19.196:2380" \
--initial-cluster-token etcd-cluster \
--initial-cluster-state new


### test ###
curl -L http://10.4.99.4:2479/v2/keys/message -XPUT -d value="Hello zhenyuyaodidiao"

curl -L http://10.4.99.4:2479/v2/keys/message

http://10.4.99.4:2379/v2/members