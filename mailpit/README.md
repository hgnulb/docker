# Mailpit 本地使用

```bash
make up DIR=mailpit
```

应用邮件配置：

```dotenv
SMTP_HOST=127.0.0.1
SMTP_PORT=1025
SMTP_SECURE=false
```

Web UI：<http://localhost:8025>。来自其他 `dev-backend` 容器的应用应使用 `mailpit:1025`，无需用户名、密码或 TLS。

Mailpit 会截获邮件而不向真实收件人投递，适合开发和集成测试。邮件保存在 `mailpit_data` volume 中，最多保留 `.env` 配置的消息数量。官方镜像内置 `/livez`、`/readyz` 健康检查。
