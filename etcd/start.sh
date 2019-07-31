
docker run -d -v /usr/share/ca-certificates/:/etc/ssl/certs -p 4001:4001 -p 2380:2380 -p 2379:2379 
--name etcd flyceek/etcd 
-name etcd0 
-advertise-client-urls http://${ETCD_HOST}:2379,http://${ETCD_HOST}:4001 
-listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 
-initial-advertise-peer-urls http://${ETCD_HOST}:2380 
-listen-peer-urls http://0.0.0.0:2380 
-initial-cluster-token etcd-cluster-1 
-initial-cluster etcd0=http://${ETCD_HOST}:2380 
-initial-cluster-state new

---------------------------------------------------------------------------------------------------------------------------------------------

rm -rf /tmp/etcd-data.tmp && mkdir -p /tmp/etcd-data.tmp && \
  docker rmi gcr.io/etcd-development/etcd:v3.3.13 || true && \
  docker run \
  -p 2379:2379 \
  -p 2380:2380 \
  --mount type=bind,source=/tmp/etcd-data.tmp,destination=/etcd-data \
  --name etcd-gcr-v3.3.13 \
  gcr.io/etcd-development/etcd:v3.3.13 \
  /usr/local/bin/etcd \
  --name s1 \
  --data-dir /etcd-data \
  --listen-client-urls http://0.0.0.0:2379 \
  --advertise-client-urls http://0.0.0.0:2379 \
  --listen-peer-urls http://0.0.0.0:2380 \
  --initial-advertise-peer-urls http://0.0.0.0:2380 \
  --initial-cluster s1=http://0.0.0.0:2380 \
  --initial-cluster-token tkn \
  --initial-cluster-state new

docker exec etcd-gcr-v3.3.13 /bin/sh -c "/usr/local/bin/etcd --version"
docker exec etcd-gcr-v3.3.13 /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl version"
docker exec etcd-gcr-v3.3.13 /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl endpoint health"
docker exec etcd-gcr-v3.3.13 /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put foo bar"
docker exec etcd-gcr-v3.3.13 /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl get foo"