# Consul 本地使用

```bash
make up DIR=consul
docker compose -f consul/compose.yaml exec consul consul members
```

- HTTP API / Web UI：<http://localhost:8500>
- DNS：`127.0.0.1:8600`，同时支持 TCP 和 UDP
- 其他 `dev-backend` 容器：`http://consul:8500`、DNS `consul:8600`
- 数据目录：`consul_data` volume

查询服务目录：

```bash
curl http://127.0.0.1:8500/v1/catalog/services
dig @127.0.0.1 -p 8600 consul.service.consul
```

这是关闭 ACL、未配置 TLS 的单 Server 开发环境，只适合本机调试。生产环境需要奇数个 Server 节点、ACL、TLS、Gossip 加密和备份策略。

Consul 当前使用 Business Source License（BSL），并非 OSI 定义的开源许可证；其较旧版本会按许可证条款转换为 MPL 2.0。
