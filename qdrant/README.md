# Qdrant 本地使用

```bash
make up DIR=qdrant
curl -H 'api-key: dev_qdrant_key' http://localhost:6333/collections
```

- REST API：`http://127.0.0.1:6333`
- gRPC：`127.0.0.1:6334`
- Dashboard：<http://localhost:6333/dashboard>
- 默认 API Key：`dev_qdrant_key`，可在 `qdrant/.env` 修改。

数据保存在 `qdrant_data` volume 中。已有数据时，升级应遵循 Qdrant 的迁移说明并按 minor 版本逐级进行；升级前先备份 snapshot，不要跨多个 minor 直接替换镜像。
