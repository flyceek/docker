docker exec -it -uroot node1 bash
### backup full ###
mkdir -p /data/backup/full-20190813-01
xtrabackup --backup -uroot -p123321 --target-dir=/data/backup/full-20190813-01

### restore full ###
docker volume rm pxc-v2
docker volume create pxc-v2
# 启动容器 bash
docker run -it \
--rm \
-p 17332:3306 \
--name=pxc-node2 \
-v pxc-backup0:/data \
-v pxc-v2:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=123321 \
-e XTRABACKUP_PASSWORD=123321 \
--privileged \
-u root \
percona/percona-xtradb-cluster \
bash

# 准备阶段
xtrabackup --prepare --target-dir=/data/backup/full-20190813-01
# 执行冷还原
xtrabackup --copy-back --target-dir=/data/backup/full-20190813-01
# 更改还原后的数据库文件属主
chown -R mysql:mysql /var/lib/mysql

# 启动容器 mysql
docker run -d \
--rm \
-p 17332:3306 \
--name=pxc-node2 \
-v pxc-backup0:/data \
-v pxc-v2:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=123321 \
-e XTRABACKUP_PASSWORD=123321 \
--privileged \
percona/percona-xtradb-cluster