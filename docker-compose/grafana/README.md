## grafana链接prometheus数据库

```text
http://prometheus:9090
```

## redis
模板编号
```text
11835
```

## mysql
模板编号
```text
7362
```
多个使用变量
```text
mysql_global_status_threads_connected{instance=~"$instance"}
```
