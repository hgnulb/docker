# Apache Flink 本地集群

```bash
make up DIR=flink WAIT_TIMEOUT=600
```

- Web UI：<http://localhost:18081>
- JobManager：`jobmanager:8081`
- 默认 1 个 TaskManager、2 个 Slot
- Checkpoint 和 Savepoint 分别保存在 named volume 中

提交示例 Job：

```bash
docker compose -f flink/compose.yaml exec jobmanager \
  flink run /opt/flink/examples/streaming/WordCount.jar
```

Flink 已加入 `dev-backend`，Job 可使用 `kafka:29092`、`mysql:3306`、`doris-fe:9030` 等服务地址。镜像默认不包含 Kafka、JDBC、Iceberg 等 Connector JAR；应按 Flink 与 Connector 的版本兼容矩阵安装，不能随意混用。
