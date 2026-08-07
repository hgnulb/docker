# OpenTelemetry 本地使用

Collector 是应用遥测数据的统一入口：

```text
OTLP metrics -> Prometheus 抓取 otel-collector:9464
OTLP logs    -> Loki  loki:3100
OTLP traces  -> Tempo tempo:4317
```

模块之间通过外部网络 `dev-backend` 和服务名通信；`.env` 中的端口只控制宿主机入口。`make up` 会自动创建网络，直接使用 Docker Compose 前应先执行一次 `make network`。

Tempo 的 `14317/14318` 是宿主机直接写入 Tempo 时的映射端口，不是 Collector 在共享网络中使用的地址。

建议先启动存储，再启动 Collector：

```bash
make up DIR=loki
make up DIR=tempo
make up DIR=otel-collector
make up DIR=alloy
make up DIR=prometheus
make up DIR=alertmanager
make up DIR=grafana
```

Collector 负责应用主动上报的 OTLP 数据；Alloy 负责自动采集 Docker 容器 stdout/stderr，二者不是重复组件。

宿主机应用配置：

```dotenv
OTEL_SERVICE_NAME=my-service
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
```

如果 Loki 或 Tempo 未启动，Collector 会保留运行并在日志中持续报告导出失败。

基础冒烟检查：

```bash
curl -fsS http://localhost:3100/ready
curl -fsS http://localhost:3200/ready
curl -fsS http://localhost:9090/-/ready
curl -fsS http://localhost:9093/-/ready
curl -fsS http://localhost:12345/-/ready
curl -fsS http://localhost:3000/api/health
```

Prometheus 抓取状态见 <http://localhost:9090/targets>。Grafana 已预置三个数据源，默认登录为 `admin/dev_grafana_password`。
