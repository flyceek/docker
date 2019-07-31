### stand-alone ###

rm -rf /tmp/etcd-data.tmp 
mkdir -p /tmp/etcd-data.tmp

docker run \
-d \
--rm \
-p 2379:2379 \
-p 2380:2380 \
--mount type=bind,source=/tmp/etcd-data.tmp,destination=/etcd-data \
--name etcd-test \
flyceek/etcd \
/usr/local/bin/etcd \
--name etcd0 \
--data-dir /etcd-data \
--listen-client-urls http://0.0.0.0:2379 \
--advertise-client-urls http://0.0.0.0:2379 \
--listen-peer-urls http://0.0.0.0:2380 \
--initial-advertise-peer-urls http://0.0.0.0:2380 \
--initial-cluster etcd0=http://0.0.0.0:2380 \
--initial-cluster-token tkn \
--initial-cluster-state new

### cluster ###

docker run --rm \
-d \
-p 2380:2380 \
-p 2479:2379 \
--name etcd0 \
flyceek/etcd \
/usr/local/bin/etcd \
-name etcd0 \
-advertise-client-urls http://192.168.3.3:2479 \ 
-listen-client-urls http://0.0.0.0:2379 \
-initial-advertise-peer-urls http://192.168.3.3:2380 \
-listen-peer-urls http://0.0.0.0:2380 \
-initial-cluster-token etcd-cluster-1 \
-initial-cluster "etcd0=http://192.168.3.3:2380,etcd1=http://192.168.3.3:2381" \
-initial-cluster-state new

docker run --rm \
-d \
-p 2381:2380 \
-p 2480:2379 \
--name etcd1 \
flyceek/etcd \
/usr/local/bin/etcd \
-name etcd1  \
-advertise-client-urls http://192.168.3.3:2480  \
-listen-client-urls http://0.0.0.0:2379 \
-initial-advertise-peer-urls http://192.168.3.3:2381 \
-listen-peer-urls http://0.0.0.0:2380  \
-initial-cluster-token etcd-cluster-1 \
-initial-cluster "etcd0=http://192.168.3.3:2380,etcd1=http://192.168.3.3:2381" \
-initial-cluster-state new


### test ###
curl -L http://10.4.99.4:2479/v2/keys/message -XPUT -d value="Hello zhenyuyaodidiao"

curl -L http://10.4.99.4:2479/v2/keys/message
