# RocketMQ 本地使用

```bash
make up DIR=rocketmq
```

| 功能 | 地址 |
|---|---|
| NameServer | `127.0.0.1:9876` |
| Broker VIP 通道 | `127.0.0.1:10909` |
| Broker | `127.0.0.1:10911` |
| Dashboard | <http://localhost:8082> |

首次启动时会看到 `volume-init` 执行后显示 `Exited (0)`，这是正常现象：它只负责把新数据卷权限交给 RocketMQ 官方镜像使用的 uid/gid 3000，不是常驻服务。

Broker 对本机客户端广播 `127.0.0.1`，所以 `10909/10911` 固定按原端口映射，不建议只改宿主机端口。Dashboard 与宿主机看到的回环地址不同，Compose 中的 `dashboard-broker-proxy` 负责转发这两个端口，它不是额外的 RocketMQ 节点。

这套默认值优先服务运行在宿主机的开发应用。如果客户端也在另一个 Docker Compose 中，不能直接使用 Broker 广播的 `127.0.0.1`；需要针对该场景调整 Broker 对外地址并进行客户端验证。

快速确认集群和 Dashboard：

```bash
docker compose -f rocketmq/compose.yaml exec broker \
  sh mqadmin clusterList -n namesrv:9876
curl -fsS http://localhost:8082/ >/dev/null
```
