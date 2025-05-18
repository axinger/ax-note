```
docker run -d \
--name mysql-exporter \
--net=mynetwork \
-p 9104:9104 \
-e DATA_SOURCE_NAME="root:123456@(192.168.101.134:3306)/" \
prom/mysqld-exporter:v0.17.2


docker network create my-mysql-network
docker pull prom/mysqld-exporter

docker run -d \
--name mysql-exporter \
-p 9104:9104 \
-v /root/mydata/mysqld_exporter/my.cnf:/.my.cnf \
--network mynetwork \
prom/mysqld-exporter:v0.17.2
