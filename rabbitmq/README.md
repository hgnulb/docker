# RabbitMQ 本地使用

```bash
make up DIR=rabbitmq
```

- AMQP：`amqp://app:dev_rabbitmq_password@127.0.0.1:5672/%2F`
- Management UI：<http://localhost:15672>
- 默认登录：`app / dev_rabbitmq_password`
- 其他 `dev-backend` 容器：`rabbitmq:5672`

数据保存在 `rabbitmq_data` volume 中。默认账号和虚拟主机只在空数据目录首次初始化时创建；已有 volume 后修改 `.env` 不会自动修改 RabbitMQ 内部账号。
