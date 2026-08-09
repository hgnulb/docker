# Meilisearch 本地使用

```bash
make up DIR=meilisearch
curl -H 'Authorization: Bearer dev_meilisearch_master_key' \
  http://localhost:7700/indexes
```

- HTTP API：`http://127.0.0.1:7700`
- 其他 `dev-backend` 容器：`http://meilisearch:7700`
- 默认 Master Key：`dev_meilisearch_master_key`，可在 `meilisearch/.env` 修改。

Meilisearch 适合需要拼写容错、前缀搜索和快速接入的站内搜索场景，比 Elasticsearch 更轻量，但不能替代其完整的日志分析和复杂聚合能力。数据保存在 `meilisearch_data` volume 中；升级前请按官方迁移说明检查版本兼容性并导出 dump。
