# PrometheusAlert 本地使用

PrometheusAlert 是可选的中文告警通知桥接服务，常用于把 Alertmanager/Grafana Webhook 转发到飞书、钉钉、企业微信、邮件等渠道。

```bash
make up DIR=prometheus-alert
```

- 页面：<http://localhost:18080>
- 默认登录：`prometheusalert/dev_prometheus_alert_password`
- 模板和路由数据保存在 `prometheus_alert_data` volume。

需要接收 Alertmanager 告警时，将 `alertmanager/alertmanager.yaml` 中的 `route.receiver` 从 `local` 改为 `prometheus-alert`，然后重新执行 `make up DIR=alertmanager`。

实际机器人地址和密钥不要提交到仓库；在 PrometheusAlert 页面创建告警组或模板，并保存在本机 volume 中。
