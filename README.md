# 1.命令

## 1.国内安装docker

```
curl -sSL https://get.daocloud.io/docker | sh
```

```
--restart=always \ 自启动
--privileged=true \ 容器内部拥有root权限
```

### 1.磁盘

```
df -h
```

![image-20230315150120299](.\img\image-20230315150120299.png)

### 2.修改软连接

docker存储路径

```
docker info | grep "Docker Root Dir"
```

停掉docker服务

```
systemctl stop docker
```

移动docker目录

```
mv /var/lib/docker /home/docker_home
```

创建软链接

- /home/docker_home为源文件目录，也就是新设置的docker存储目录
- /var/lib/docker为软链接目标目录，与此目录建立链接后，相当于原来的docker配置保持不变，但真正的存储目录是其背后所指向的/home/docker_home

```
ln -s /home/docker_home /var/lib/docker
```

启动docker服务

```
systemctl start docker
```

查看/var/lib/目录，docker目录是一个软链接，指向/home/docker_home，配置正确

```
ls -al /var/lib
```

```
ll /var/lib/docker
```

![image-20230315150239718](.\img\image-20230315150239718.png)

## 2.查看气启动参数

```
runlike 容器
```

## 3.系统开关机命令

```
启动: systemctl start docker
停止: systemctl stop docker
重启: systemctl restart docker
查看状态: systemctl status docker
开机启动: systemctl enable docker
```



## 4.镜像命令

### 1.基础命令

```
查看概要: docker info
查看本地镜像: docker images
拉取镜像: docker pull
查看存储: docker system df
强制删除镜像: docker rmi -f
查看已下载的Docker镜像latest具体版本
docker image inspect (docker image名称):latest|grep -i version
导出镜像: docker save -o test.tar mysql:8.0.28
导入镜像: docker load -i test.tar
docker tag 标签
```

### 2.无法删除镜像

```
cd /var/lib/docker/image/overlay2/imagedb/content/sha256
```

```
rm -rf 文件名(输入docker images 查询到的简称,tab出全程)
```

### 3.镜像导出导入

```
docker save nginx > Nginx.tar
```

```
docker load < Nginx.tar
```

### 4.容器导出导入

```
docker export b91d9ad83efa > tomcat80824.tar
```

```
docker import tomcat80824.tar
```



## 5.容器命令



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

### 1.容器cup 内存等信息

```
docker stats
```

![image-20221027155151408](.\img\.gitignore)

### 2.复制文件

```
docker cp 容器名:容器内路径 目的主机路径 
```

### 3.日志

后台运行查询指定数量最新log

```
docker logs -f -t --tail=5 容器名
```

### 4.创建完成的容器修改启动参数

```
docker container update restart=always 容器名或id
```

## 6.制作镜像

### 1.java

Dockerfile

```
FROM eclipse-temurin:17-jre-alpine

VOLUME /tmp

#RUN cd /
# eclipse-temurin:17-jre-alpine 没有mkdir命令
#RUN bash -c 'mkdir -p {config,target}'
COPY /target/*.jar /server.jar

# 自动识别config/application.yml
ENTRYPOINT ["java","-jar","/server.jar"]

#配置时区，不然会发现打包到docker中启动的容器日志里的时间是差8个小时的
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo 'Asia/Shanghai' >/etc/timezone \

# docker 命令 对应的idea运行配置
# restart=always; privileged=true;
# idea运行配置
# --restart=always --privileged=true

# 暴露端口,需要和服务的端口一致
EXPOSE 11090

```

### 2. nginx 

Dockerfile

```
FROM nginx:1.23.2-alpine

# 删除nginx 默认配置
RUN rm /etc/nginx/conf.d/default.conf
# 添加我们自己的配置 default.conf 在下面
ADD docker/default.conf /etc/nginx/conf.d/
# 把刚才生成dist文件夹下的文件copy到nginx下面去
COPY dist/  /usr/share/nginx/html/

# --restart=always --privileged=true
EXPOSE 80

```

nginx的配置文件 default.conf

```
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    location  ^~ /baseApi/ {
        proxy_pass   http://192.168.101.143:12701/;
    }
  location  ^~ /gatewayApi/ {
        proxy_pass   http://192.168.101.134:30011/;
    }



    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}

```





# 2.常用容器

## portainer-ce 图形界面

### 命令

```
mkdir -p /home/portainer/data
```

```
/var/run/docker.sock:/var/run/docker.sock 是固定值,docker的内容
```

```
docker run -d  --name portainer -p 900:9000 -v /var/run/docker.sock:/var/run/docker.sock -v /home/portainer/data:/data --restart always --privileged=true portainer/portainer-ce:latest
```

```
admin
abcd1234567890
```



## mysql

### 命令

```
mkdir -p /home/mysql8/{data,logs,conf}
```

```
docker run \
--name mysql8 -d \
-p 3306:3306 \
-e MYSQL_ROOT_PASSWORD=123456 \
mysql:8.0.28
```

```
docker cp mysql8:/etc/mysql/my.cnf /home/mysql8/conf/my.cnf
```

```
docker run \
--name mysql8 -d \
-p 3306:3306 \
--network demo-network \
-e MYSQL_ROOT_PASSWORD=123456 \
--restart=always \
--privileged=true \
-v /home/mysql8/data:/var/lib/mysql \
-v /home/mysql8/logs:/var/log/mysql \
-v /home/mysql8/conf/my.cnf:/etc/mysql/my.cnf \
mysql:8.0.28
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

### 命令

```
docker run --name demo-pgsql  -d \
-e POSTGRES_PASSWORD=123456 \
-p 5432:5432 \
-v /home/postgresql/data:/var/lib/postgresql/data \
postgres:14.6-alpine
```

### 修改连接

```
docker exec -it demo-pgsql bash
```

```
psql -h localhost -p 5432 -U postgres --password
```



## nacos

### 低版本(1.4.x)

```
挂载的文是/home/nacos/init.d/custom.properties
```

```
docker pull nacos/nacos-server:1.4.0

mkdir -p /home/nacos1/{init.d,conf}

docker run --name nacos -d \
-e MODE=standalone \
-p 8848:8848 \
--restart=always \
-v /home/nacos/logs:/home/nacos/logs \
-v /home/nacos/init/custom.properties:/home/nacos/init.d/custom.properties \
nacos/nacos-server:1.4.0
```

### 1.4.2 及 2.0.3版本

```
mkdir -p /home/nacos/{logs,conf}
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
docker cp nacos:/home/nacos/conf/application.properties /home/nacos/conf/application.properties
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
-v /home/nacos/logs:/home/nacos/logs \
-v /home/nacos/conf/application.properties:/home/nacos/conf/application.properties \
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
-v /home/seata/conf/registry.conf:/seata-server/resources/registry.conf \
-v /home/seata/conf/file.conf:/seata-server/resources/file.conf \
-v /home/seata/logs:/root/logs \
seataio/seata-server:1.4.2
```

### 持久化SQL

```
新版本 seata+nacos 需要在nacos导入配置文件,官网执行sh脚本
https://github.com/seata/seata/blob/develop/script/server/db/mysql.sql
```



## redis

建立挂载目录

```
mkdir -p /home/redis/conf
chmod -R 777 /home/redis
```

```
没有配置文件这件事呢！那是因为redis容器里边的配置文件是需要在创建容器时映射进来的
https://github.com/redis/redis/blob/unstable/redis.conf 
下载文件,进行映射
```

```
docker exec -it redis7 sh
```

### 命令

```
docker run --name redis7 -d \
-p 6379:6379 \
--privileged=true \
--restart=always \
-v /home/redis/redis.conf:/etc/redis/redis.conf \
-v /home/redis/data:/data \
redis:7.0.4 redis-server /etc/redis/redis.conf

```

## nginx

### 建立挂载目录

```
mkdir -p /home/nginx/{conf,conf.d,html,log}

docker run --name demo-nginx -p 8080:80 -d nginx
docker cp demo-nginx:/etc/nginx/nginx.conf /home/nginx/conf/nginx.conf

docker cp demo-nginx:/etc/nginx/conf.d/default.conf /home/nginx/conf.d/default.conf
```

### 命令

```
docker run --name demo-nginx -d \
-p 3500:80 \
--network demo-network \
-v /home/nginx/html:/usr/share/nginx/html \
-v /home/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
-v /home/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf \
-v /home/nginx/log:/var/log/nginx \
nginx:1.21.6-alpine
```

```
docker run -i -t --network demo-network   -p 50070:50070 -p 9000:9000 -p 8088:8088 -p 8040:8040 -p 8042:8042  -p 49707:49707  -p 50010:50010  -p 50075:50075  -p 50090:50090 sequenceiq/hadoop-docker:2.6.0 /etc/bootstrap.sh -bash
```

```
配置请求转发,在conf.d/default.conf 中配置
```



## mongodb

### 文件夹

```
mkdir -p /home/mongodb/{data,conf,backup}
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
-v /home/mongodb/data:/data/db \
-v /home/mongodb/backup:/data/backup \
-v /home/mongodb/conf:/data/configdb \
mongo:4.4.13-focal
```

## minio

### 命令

```
mkdir -p /home/minio/{data,conf}
```

```
docker run -p 19000:9000 -p 9031:9001 --name minio19000 \
-d --restart=always \
--privileged=true \
-e TZ="Asia/Shanghai" \
-e MINIO_ROOT_USER=admin \
-e MINIO_ROOT_PASSWORD=admin123 \
-v /home/minio/data:/data \
-v /home/minio/conf:/root/.minio \
minio/minio:RELEASE.2022-04-12T06-55-35Z server /data --console-address ":19001"
```

## keycloak

#### 命令

```
docker run --name keycloak -d -p 7010:8080 -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin jboss/keycloak:16.0.0
```

禁用https

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

#### 命令

```
docker run --name rabbitmq -d \
--privileged=true \
--restart=always \
-d -p 5672:5672 -p 15672:15672 \
-v /home/rabbitmq/data:/var/lib/rabbitmq \
-v /home/rabbitmq/conf:/etc/rabbitmq \
-v /home/rabbitmq/log:/var/log/rabbitmq \
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

## rocketmq

### 命令

```
mkdir -p /home/rocketmq/logs /home/rocketmq/store

```

```
docker run -d --restart=always --name rocketmq \
--privileged=true -p 9876:9876 \
-v /home/rocketmq/logs:/root/logs \
-v /home/rocketmq/store:/root/store \
-e "MAX_POSSIBLE_HEAP=100000000" \
rocketmqinc/rocketmq:4.9.4 sh mqnamesrv

```



## elk

### 命令

```
使用 docker compose
```

## kafaka

### 命令

```
使用 docker compose
```

测试工具

```
docker run -d -p 8889:8889 freakchicken/kafka-ui-lite
```



## pulsar

### 命令

```
docker run -it -d --name=demo-pulsar \
-p 6650:6650  -p 17080:8080 \
--mount source=pulsardata,target=/root/mydata/pulsar/data \
--mount source=pulsarconf,target=/root/mydata/pulsar/conf \
apachepulsar/pulsar:2.10.2 \
bin/pulsar standalone
```

```
docker run -d -it --name=pulsar-manager \
-p 17081:9527 -p 7750:7750 \
-e SPRING_CONFIGURATION_FILE=/pulsar-manager/pulsar-manager/application.properties \
--link pulsar-standalone \
apachepulsar/pulsar-manager:v0.3.0
```

