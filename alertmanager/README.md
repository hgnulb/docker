# Alertmanager 本地使用

Alertmanager 接收 Prometheus 告警，负责分组、去重、静默和通知路由。

```bash
make up DIR=alertmanager
```

- 管理页面：<http://localhost:9093>
- 默认不启用认证，仅限本机开发。
- 数据和静默规则保存在 `alertmanager_data` volume。

`alertmanager.yaml` 默认使用空的 `local` receiver，告警只显示在 UI，不发送外部通知。若同时启动 `prometheus-alert`，把 `route.receiver` 改为 `prometheus-alert`，再执行：

```bash
make up DIR=alertmanager
```

发送一条测试告警：

```bash
curl -X POST http://localhost:9093/api/v2/alerts \
  -H 'Content-Type: application/json' \
  -d '[{"labels":{"alertname":"LocalSmokeTest","severity":"info"},"annotations":{"summary":"本地测试告警"}}]'
```
