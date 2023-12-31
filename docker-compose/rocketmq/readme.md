
docker-compose 

进入 本目录下,执行如下命令
```bash
chmod +x  start.sh

./start.sh
```

清除 已创建的 docker
```bash
docker-compose down

# 删除 产生的 日志及临时文件
rm -rf ./rmqs/logs/*
rm -rf  ./rmqs/store/*
rm -rf  ./rmq/logs/*
rm -rf  ./rmq/store/*
```

```
把 /rmq/brokerconf/broker.conf 复制进去
```

```
brokerIP1=192.168.101.143   改为对应ip
```

