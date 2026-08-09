# n8n 本地使用

首次启动前建议生成独立加密密钥：

```bash
make init DIR=n8n
openssl rand -hex 32
# 将结果写入 n8n/.env 的 N8N_ENCRYPTION_KEY
make up DIR=n8n
```

打开 <http://localhost:5678>，首次访问时创建本地所有者账号。工作流、凭据和二进制数据保存在 `n8n_data` volume 中。

n8n 已加入 `dev-backend` 网络，工作流可用服务名访问仓库中的共享模块，例如 `mysql:3306`、`redis:6379`、`rabbitmq:5672` 和 `mailpit:1025`。访问宿主机进程时可使用 `host.docker.internal`。

本模块为单实例本地开发配置，使用 n8n 默认的 SQLite 数据库。队列模式、外部 Task Runner、PostgreSQL、反向代理和 HTTPS 应按正式部署需求单独设计。当前以 HTTP 方式仅绑定本机，因此设置了 `N8N_SECURE_COOKIE=false`；接入 HTTPS 时应删除该设置或改为 `true`。

`N8N_ENCRYPTION_KEY` 用于加密保存的凭据，已有数据后不要更换，否则旧凭据将无法解密。n8n 使用 fair-code 许可证，并非 OSI 定义的开源许可证。
