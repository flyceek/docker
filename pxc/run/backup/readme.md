docker exec -it -uroot node1 bash
### backup full ###
xtrabackup --backup -uroot -p123321 --target-dir=/tmp/data/backup/full

### restore full ###
# 准备阶段
xtrabackup --prepare --target-dir=/data/backup/full/
# 执行冷还原
xtrabackup --copy-back --target-dir=/data/backup/full/