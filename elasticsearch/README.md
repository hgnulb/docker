# ELK 本地使用

该模块包含 Elasticsearch、Logstash 和 Kibana，三个组件使用同一个 Elastic 8.19.17 版本。

```bash
make up DIR=elasticsearch WAIT_TIMEOUT=600
```

本地入口：

- Elasticsearch API：`http://127.0.0.1:9200`
- Kibana：<http://localhost:5601>
- Logstash JSON Lines TCP：`127.0.0.1:5000`
- Logstash Beats：`127.0.0.1:5044`
- Logstash Monitoring API：`http://127.0.0.1:9600`

发送一条 JSON 日志：

```bash
printf '%s\n' '{"message":"hello ELK","service":"demo","level":"INFO"}' \
  | nc 127.0.0.1 5000
curl 'http://127.0.0.1:9200/dev-logs-*/_search?pretty'
```

默认管道位于 `pipeline/logstash.conf`，接收 JSON Lines 和 Beats 事件，写入每日 `dev-logs-*` 索引。Logstash 使用持久化队列，队列数据保存在 `logstash_data` volume 中。

三个服务均关闭认证或未配置入口认证，只适合本机开发。完整 ELK 比单独启动 Elasticsearch/Kibana 多占用约 512 MB JVM Heap 及额外进程内存；可通过 `.env` 调整 `LOGSTASH_HEAP`。
