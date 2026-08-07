# Langfuse 本地使用

该模块内部包含 Langfuse Web、Worker、PostgreSQL、ClickHouse、Redis 和 MinIO。它是一个整体，不复用仓库中的同名独立模块。

## 首次启动

```bash
make init DIR=langfuse
openssl rand -base64 32 # LANGFUSE_NEXTAUTH_SECRET
openssl rand -base64 32 # LANGFUSE_SALT
openssl rand -hex 32    # LANGFUSE_ENCRYPTION_KEY
# 将三个结果分别写入 langfuse/.env
make up DIR=langfuse WAIT_TIMEOUT=600
```

建议同时修改 `.env` 中所有 `dev_langfuse_*` 密码。完整栈建议为 Docker 分配约 4 核 CPU、16 GB 内存；首次初始化可能需要几分钟。

`LANGFUSE_ENCRYPTION_KEY` 必须是 64 位十六进制字符串，已有数据后不要更换，否则已加密内容将无法解密。

| 功能 | 地址 |
|---|---|
| Langfuse Web | <http://localhost:3300> |
| MinIO API | `http://localhost:19090` |
| MinIO Console | <http://localhost:19091> |

Langfuse Web 没有预置用户，第一次访问时自行注册。内部 MinIO 登录为 `minio/dev_langfuse_minio`，修改 `.env` 后以实际值为准。

应用 SDK 使用 Langfuse UI 创建的项目公钥和私钥，不要使用基础设施数据库密码。

该 Compose 适合本地开发和单机体验，不提供高可用、横向扩容或自动备份。
