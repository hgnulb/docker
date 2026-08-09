# Apache Doris 本地集群

该模块包含 1 个 FE 和 1 个 BE，建议至少为 Docker 预留 4 CPU、8 GB 内存。

```bash
make up DIR=doris WAIT_TIMEOUT=900
mysql -h127.0.0.1 -P9030 -uroot \
  -e 'SELECT host, join, alive FROM frontends(); SELECT host, alive FROM backends();'
```

- FE Web UI：<http://localhost:18030>
- MySQL 协议：`127.0.0.1:9030`，默认 `root` 空密码
- BE Web：<http://localhost:18040>

FE 元数据、BE 数据和日志均使用 named volume 持久化。该单副本配置只适合本地开发；生产环境需要多 FE/BE、副本、资源隔离、认证、备份及磁盘规划。
