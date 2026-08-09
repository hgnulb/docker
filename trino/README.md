# Trino 本地使用

```bash
make up DIR=trino
docker compose -f trino/compose.yaml exec trino \
  trino --execute 'SELECT count(*) FROM tpch.tiny.nation'
```

- Web UI / API：<http://localhost:18084>
- JDBC：`jdbc:trino://127.0.0.1:18084`
- 内置示例 Catalog：`tpch`、`tpcds`
- 预置 Catalog：`mysql`、`postgresql`、`clickhouse`

Catalog 文件中的密码对应本仓库各模块 `.env.example` 默认值。如果修改了数据库密码，应同步修改 `trino/catalog/*.properties`。下游数据库未启动不会影响 Trino 本身启动，但查询对应 Catalog 会失败。

Trino 是查询引擎而不是数据库，不负责持久化业务表。生产环境应部署独立 Coordinator/Worker、认证、TLS、资源组和 Catalog 密钥管理。
