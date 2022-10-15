# docker

## 安装和命令

### 国内安装docker

```
curl -sSL https://get.daocloud.io/docker | sh
```

```
--restart=always \ 自启动
--privileged=true \ 容器内部拥有root权限
```

### 创建完成的容器修改启动参数

```
docker container update restart=always 容器名或id
```

### 查看气启动参数

```
runlike 容器
```



### 系统开关机命令

```
启动: systemctl start docker
停止: systemctl stop docker
重启: systemctl restart docker
查看状态: systemctl status docker
开机启动: systemctl enable docker
```

### 镜像命令

```
查看概要: docker info
查看本地镜像: docker images
拉取镜像: docker pull
查看存储: docker system df
强制删除镜像: docker rmi -f
查看已下载的Docker镜像latest具体版本
docker image inspect (docker image名称):latest|grep -i version
```

### 容器命令

```
启动交互式容器(前台命令行)

查看运行的容器: docker ps 
显示所有的容器，包括未运行的: docker ps -a
    停止后无法查看,要查看需要运行的,可以用 docker images 查找容器id 也可以用 docker ps -n 2 最近使用的
查看已经停止的: docker ps -n 2
进入容器: docker exec -it 容器id /bin/bash

退出
容器关闭:   exit 
容器不停止:  ctrl+p+q 

启动已经停止的容器id: docker start 容器id
重启容器: docker restart 容器id
停止容器: docker stop 容器id
强制停止容器: docker kill 容器id
删除已停止容器: docker rm

开机启动 docker update --restart=always  xx
```

### 查看容器运行状态

```
docker stats 
```

### 复制文件到容器

```
docker cp 容器di:容器内路径 目的主机路径
```

## portainer-ce 图形界面

### 命令

```
docker run -d  --name portainer -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v /app/portainer_data:/data --restart always --privileged=true portainer/portainer-ce:latest
```



## mysql

### 命令

```
docker run \
--name mysql8 -d \
-p 3306:3306 \
--network demo-network \
--network-alias mysql8 \
-e MYSQL_ROOT_PASSWORD=123456 \
--restart=always \
--privileged=true \
-v ~/mydata/mysql8/data:/var/lib/mysql \
-v ~/mydata/mysql8/logs:/var/log/mysql \
-v ~/mydata/mysql8/conf/my.cnf:/etc/mysql/my.cnf \
mysql:8.0.28
```

```
docker cp mysql8:/etc/mysql/my.cnf ~/mydata/mysql8/conf/my.cnf
```



### 配置文件 my.cnf

```
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

# Custom config should go here
!includedir /etc/mysql/conf.d/


## 阿里云,下面不要使用
# 默认使用“mysql_native_password”插件认证
default_authentication_plugin= mysql_native_password
#Accept connections from any IP address,客户端远程
bind-address = 0.0.0.0

# 设置mysql客户端默认字符集
default-character-set=utf8
[client]
# 设置mysql客户端连接服务端时默认使用的端口
port=3306
default-character-set=utf8
```

### Navicat链接问题

```
docker exec -it mysql8 /bin/bash
mysql -u root -p
use mysql;
update user set host = '%' where user ='root';
flush privileges;
```

##  postgres

```
docker run --name demo-pgsql  -d \
--network demo-network \
-e POSTGRES_PASSWORD=postgres \
-p 5432:5432 \
-v ~/mydata/pgsql/data:/var/lib/postgresql/data \
postgres
```



## nacos

### 低版本(1.4.x)

```
挂载的文是/home/nacos/init.d/custom.properties
```

```
docker pull nacos/nacos-server:1.4.0

mkdir -p ~/mydata/nacos1/{init.d,conf}

docker run --name nacos -d \
-e MODE=standalone \
-p 8848:8848 \
--restart=always \
-v ~/mydata/nacos/logs:/home/nacos/logs \
-v ~/mydata/nacos/init/custom.properties:/home/nacos/init.d/custom.properties \
nacos/nacos-server:1.4.0
```

### 1.4.2 及 2.0.3版本

```
mkdir -p ~/mydata/nacos/{logs,conf}
```

````
修改内存大小
-e JVM_XMS=128m \
-e JVM_XMX=128m \
-e JVM_XMN=64m \
````

```
挂载的文件是/home/nacos/conf/application.properties
```

##### 复制配置文件

```
docker  run \
--name nacos -d \
-p 8848:8848 \
nacos/nacos-server:v2.0.4
```

```
docker cp nacos:/home/nacos/conf/application.properties ~/mydata/nacos/conf/application.properties
```

```
docker stop nacos 
docker rm nacos
```



```
docker  run \
--name nacos -d \
-p 8848:8848 \
--network demo-network \
--privileged=true \
--restart=always \
-e MODE=standalone \
-v ~/mydata/nacos/logs:/home/nacos/logs \
-v ~/mydata/nacos/conf/application.properties:/home/nacos/conf/application.properties \
nacos/nacos-server:v2.0.4
```

##### 持久化SQL,注意版本

```
https://github.com/alibaba/nacos/blob/2.0.4/distribution/conf/nacos-mysql.sql
```

## seata

### 命令

```
docker run --name demo-seata -d \
-p 8091:8091 \
--network demo-network \
--privileged=true \
--restart=always \
-e SEATA_PORT=8091 \
-v ~/mydata/seata/conf/registry.conf:/seata-server/resources/registry.conf \
-v ~/mydata/seata/conf/file.conf:/seata-server/resources/file.conf \
-v ~/mydata/seata/logs:/root/logs \
seataio/seata-server:1.4.2
```

### 持久化SQL

```
新版本 seata+nacos 需要在nacos导入配置文件,官网执行sh脚本
https://github.com/seata/seata/blob/develop/script/server/db/mysql.sql
```



## redis

### 命令

```
docker run --name redis6 -d \
-p 6379:6379 \
--privileged=true \
--restart=always \
--network demo-network \
-v ~/mydata/redis/conf:/etc/redis.conf \
-v ~/mydata/redis/data:/data \
redis:6.2.7-alpine3.15
```

## nginx

### 建立挂载目录

```
mkdir -p ~/mydata/nginx/{conf,conf.d,html,log}

docker run --name demo-nginx -p 8080:80 -d nginx
docker cp demo-nginx:/etc/nginx/nginx.conf ~/mydata/nginx/conf/nginx.conf

docker cp demo-nginx:/etc/nginx/conf.d/default.conf ~/mydata/nginx/conf.d/default.conf
```

### 命令

```
docker run --name demo-nginx -d \
-p 3500:80 \
--network demo-network \
-v ~/mydata/nginx/html:/usr/share/nginx/html \
-v ~/mydata/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
-v ~/mydata/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf \
-v ~/mydata/nginx/log:/var/log/nginx \
nginx:1.21.6-alpine
```

```
docker run -i -t --network demo-network   -p 50070:50070 -p 9000:9000 -p 8088:8088 -p 8040:8040 -p 8042:8042  -p 49707:49707  -p 50010:50010  -p 50075:50075  -p 50090:50090 sequenceiq/hadoop-docker:2.6.0 /etc/bootstrap.sh -bash
```



## mongodb

### 文件夹

```
mkdir -p ~/mydata/mongodb/{data,conf,backup}
```

### mongodb.conf

```
# mongodb.conf
logappend=true
# 被远程
# bind_ip=127.0.0.1
port=27017 
fork=true
noprealloc=true
auth=true
```



### 命令

```
docker run --name mongodb -d \
-p 27017:27017 \
--network=demo-network \
--privileged=true \
-e MONGO_INITDB_ROOT_USERNAME=admin \
-e MONGO_INITDB_ROOT_PASSWORD=admin123 \
-v ~/mydata/mongodb/data:/data/db \
-v ~/mydata/mongodb/backup:/data/backup \
-v ~/mydata/mongodb/conf:/data/configdb \
mongo:4.4.13-focal
```

## minio

### 命令

```
docker run -p 9030:9000 -p 9031:9001 --name minio \
-d --restart=always \
--privileged=true \
-e TZ="Asia/Shanghai" \
-e MINIO_ROOT_USER=admin \
-e MINIO_ROOT_PASSWORD=admin123 \
-v ~/mydata/minio/data:/data \
-v ~/mydata/minio/config:/root/.minio \
minio/minio:latest server /data --console-address ":9001"
```

## keycloak

```
docker run --name keycloak -d -p 7010:8080 -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin jboss/keycloak:16.0.0
```

```
docker exec -it keycloak bash
```

```
cd /opt/jboss/keycloak/bin  # 在opt里面,每个版本不一样,
```

```
./kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin 
```

```
./kcadm.sh update realms/master -s sslRequired=NONE
```

## rabbitmq

### 命令

```
docker run --name rabbitmq -d \
--privileged=true \
--restart=always \
-d -p 5672:5672 -p 15672:15672 \
-v ~/mydata/rabbitmq/data:/var/lib/rabbitmq \
-v ~/mydata/rabbitmq/conf:/etc/rabbitmq \
-v ~/mydata/rabbitmq/log:/var/log/rabbitmq \
--hostname=rabbitmqhost \
-e RABBITMQ_DEFAULT_VHOST=my_vhost \
-e RABBITMQ_DEFAULT_USER=admin \
-e RABBITMQ_DEFAULT_PASS=123456 \
rabbitmq:3.9.20-management-alpine
```

### 进入bin开启管理页面

```
docker exec -it rabbitmq /bin/bash
```

```
rabbitmq-plugins enable rabbitmq_management
```

## elk