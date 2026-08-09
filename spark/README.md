# Apache Spark 本地集群

```bash
make up DIR=spark WAIT_TIMEOUT=600
```

- Master：`spark://127.0.0.1:17077`
- Master UI：<http://localhost:18082>
- Worker UI：<http://localhost:18083>

运行内置示例：

```bash
docker compose -f spark/compose.yaml exec spark-master \
  /opt/spark/bin/spark-submit \
  --master spark://spark-master:7077 \
  --class org.apache.spark.examples.SparkPi \
  /opt/spark/examples/jars/spark-examples_2.13-4.1.2.jar 10
```

默认 Worker 使用 2 Core、2 GB 内存，可在 `.env` 调整。连接 Kafka、Iceberg、JDBC、S3/MinIO 时需要为 `spark-submit` 提供与 Spark 4.1/Scala 2.13 匹配的依赖包。
