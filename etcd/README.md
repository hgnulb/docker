# etcd 本地使用

```bash
make up DIR=etcd
docker compose -f etcd/compose.yaml exec etcd \
  etcdctl --endpoints=http://127.0.0.1:2379 endpoint health
docker compose -f etcd/compose.yaml exec etcd etcdctl put greeting hello
docker compose -f etcd/compose.yaml exec etcd etcdctl get greeting
```

- 宿主机客户端：`http://127.0.0.1:2379`
- 其他 `dev-backend` 容器：`http://etcd:2379`
- 数据目录：`etcd_data` volume

这是无认证、无 TLS 的单节点开发配置，仅绑定宿主机回环地址，不适合共享或生产环境。`2380` Peer 端口只在 Docker 网络内部使用，没有映射到宿主机。

升级已有数据时应遵循 etcd 官方升级顺序，先创建 snapshot，不要直接跨多个 minor 或 major 替换镜像。当前配置会定期压缩旧版本，但不会自动执行磁盘碎片整理。
