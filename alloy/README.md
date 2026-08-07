# Grafana Alloy 本地使用

Alloy 自动发现本机 Docker 容器，把容器的 stdout/stderr 日志写入 Loki，是已经 EOL 的 Promtail 的官方替代方案。

```bash
make up DIR=loki
make up DIR=alloy
```

- Alloy UI：<http://localhost:12345>
- 日志在 Grafana Explore 中选择 Loki 后查询，例如 `{platform="docker"}`。
- 采集位点保存在 `alloy_data` volume，重启后不会从头重复读取全部日志。

Alloy 挂载了 `/var/run/docker.sock`。即使标记为只读，Docker socket 仍具有较高权限，因此该配置仅用于可信的本地开发环境。
