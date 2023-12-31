#!/bin/bash
# 创建目录
# mkdir -p ./nameserver/{logs,store}
# mkdir -p ./broker/{logs,store,conf}


# 设置目录权限
chmod -R 777 ./nameserver/{logs,store}
chmod -R 777 ./broker/{logs,store,conf}


# 下载并启动容器，且为 后台 自动启动
docker compose up -d


# 显示 rocketmq 容器
docker ps |grep rocketmq
