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


docker run -d -v /usr/share/ca-certificates/:/etc/ssl/certs \
-p 4001:4001 \
-p 2380:2380 \
-p 2379:2379 \
--name etcd flyceek/etcd \
-name etcd0 \
-advertise-client-urls http://10.4.99.4:2379,http://10.4.99.4:4001 \
-listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
-initial-advertise-peer-urls http://10.4.99.4:2380 \
-listen-peer-urls http://0.0.0.0:2380 \
-initial-cluster-token etcd-cluster-1 \
-initial-cluster etcd0=http://10.4.99.4:2380 \
-initial-cluster-state new