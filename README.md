# Docker 本地后端开发环境

这个仓库集中管理后端开发常用的数据库、消息队列、注册配置中心、可观测性和 AI 基础设施。

设计原则：

- 一个一级目录就是一个独立模块，例如 `mysql/`、`redis/`、`kafka/`。
- 不提供“全部启动”命令，按项目需要单独启动，减少内存和磁盘占用。
- 所有宿主机端口默认只绑定 `127.0.0.1`，避免意外暴露到局域网。
- 数据默认写入 Docker named volume，普通停止不会丢失。
- `compose.yaml` 提供开箱即用的本地默认值，`.env` 用于覆盖当前电脑的实际配置。

> 这些配置面向本地开发和集成测试，不是生产部署方案。

## 环境要求

- Docker Desktop，或 Docker Engine + Docker Compose v2。
- 建议 Docker 至少分配 4 GB 内存；同时运行 Elasticsearch、Langfuse 等较重模块时建议 8 GB 以上。
- Langfuse 完整栈较重，若要稳定运行，建议为 Docker 分配约 4 核 CPU、16 GB 内存。
- Apple Silicon 可以运行绝大多数 ARM64 镜像。XXL-JOB 3.4.0 官方镜像仅有 AMD64，会由 Docker Desktop 模拟运行。

先检查本机环境：

```bash
make doctor
```

## 快速开始

以下 `make` 命令都在仓库根目录执行。本仓库没有“一键启动全部”目标，每个模块按需单独启动。

查看可用模块：

```bash
make list
```

启动 Redis：

```bash
make up DIR=redis
```

第一次启动时，Makefile 会自动执行：

```text
redis/.env.example -> redis/.env
```

随后可以修改 `redis/.env`，再让 Compose 应用新配置：

```bash
make up DIR=redis
```

`make restart` 只重启已经存在的容器，不会读取新配置并重建容器；修改 `.env` 或 `compose.yaml` 后应再次执行 `make up`。

也可以直接使用 Docker Compose；先确保共享网络存在（只需一次）：

```bash
docker network inspect dev-backend >/dev/null 2>&1 || docker network create dev-backend
cd redis
cp .env.example .env
docker compose up -d --wait
docker compose logs -f
docker compose down
```

## Makefile 命令

| 命令 | 作用 |
|---|---|
| `make help` | 查看命令帮助 |
| `make list` | 列出所有模块 |
| `make doctor` | 检查 Docker/Compose 是否可用 |
| `make network` | 创建跨模块通信所需的共享网络 |
| `make init DIR=mysql` | 创建该模块的 `.env`，已有文件不会覆盖 |
| `make up DIR=mysql` | 创建网络、初始化 `.env` 并启动；等待已配置的健康检查 |
| `make down DIR=mysql` | 停止模块，保留数据 |
| `make restart DIR=mysql` | 仅重启现有容器，不应用 `.env`/Compose 变更 |
| `make ps DIR=mysql` | 查看容器状态 |
| `make logs DIR=mysql` | 持续查看最近 200 行日志 |
| `make pull DIR=mysql` | 拉取该模块镜像 |
| `make config DIR=mysql` | 查看环境变量展开后的最终 Compose |
| `make validate` | 校验仓库内全部 Compose |
| `make clean DIR=mysql CONFIRM=1` | 停止模块并永久删除其数据卷 |

`clean` 是破坏性操作，没有 `CONFIRM=1` 时会拒绝执行。

## `.env.example` 和 `.env`

| 文件 | 是否提交 Git | 用途 |
|---|---:|---|
| `.env.example` | 是 | 可共享的配置模板和本地默认值 |
| `.env` | 否 | 当前电脑真实使用的端口、密码和密钥 |

Docker Compose 自动读取 `.env`，不会自动读取 `.env.example`。Compose 中同时保留了开发默认值，所以创建一次共享网络后，即使不复制 `.env`，也可以直接进入目录执行 `docker compose up -d`；推荐先生成 `.env`，便于明确记录本机覆盖项。

升级仓库后，新的 `.env.example` 不会自动合并到已有 `.env`。可以先比较，再手工补充新增项：

```bash
diff -u redis/.env.example redis/.env
```

数据库用户名、初始密码和初始化脚本通常只在空数据卷第一次启动时生效。已有 volume 时，修改 `.env` 不会自动修改数据库内部账号或密码。

不要把真实密码、Token 或生产配置写入 `.env.example`。

## 跨模块通信

需要互相访问的模块加入外部网络 `dev-backend`，例如 MySQL、Canal、Kafka，以及 Loki、Tempo、Collector、Alloy、Prometheus、Alertmanager、Grafana。`make up` 会自动创建这个网络；直接使用 `docker compose` 时，先在仓库根目录执行一次 `make network`。

共享网络只提供服务发现，不会把模块一起启动。容器间使用固定的服务名和容器端口，例如 `mysql:3306`、`loki:3100`；各模块 `.env` 中的端口变量只控制宿主机入口，因此修改宿主机端口不会破坏内部链路。

## 模块与端口

| 目录 | 内容 | 默认本地入口 |
|---|---|---|
| `mysql` | MySQL 8.4 | `127.0.0.1:3306` |
| `postgres` | PostgreSQL 17 | `127.0.0.1:5432` |
| `mongodb` | MongoDB 8 | `127.0.0.1:27017` |
| `redis` | Redis 7.4 | `127.0.0.1:6379` |
| `minio` | MinIO + Console | `9000`、<http://localhost:9001> |
| `clickhouse` | ClickHouse | HTTP `8123`、Native `19000` |
| `elasticsearch` | Elasticsearch + Kibana | `9200`、<http://localhost:5601> |
| `kafka` | Kafka KRaft + Kafka UI | `9092`、<http://localhost:8081> |
| `rocketmq` | NameServer + Broker + Dashboard | `9876/10909/10911`、<http://localhost:8082> |
| `zookeeper` | ZooKeeper | `2181` |
| `nacos` | Nacos 注册/配置中心 | `8848/9848`、<http://localhost:18000> |
| `apollo` | Apollo + 独立 MySQL | Portal <http://localhost:8070>、Config `8080`、Admin `8090` |
| `sentinel` | Sentinel Dashboard | <http://localhost:8858> |
| `xxl-job` | XXL-JOB + 独立 MySQL | <http://localhost:8083/xxl-job-admin> |
| `canal` | Canal Server | `11111/11110/11112` |
| `nginx` | Nginx 本地网关 | <http://localhost> |
| `prometheus` | Prometheus | <http://localhost:9090> |
| `alertmanager` | Prometheus 告警分组与路由 | <http://localhost:9093> |
| `prometheus-alert` | 飞书/钉钉/企微等通知桥接 | <http://localhost:18080> |
| `grafana` | Grafana | <http://localhost:3000> |
| `loki` | Loki 日志存储 | `3100` |
| `tempo` | Tempo 链路存储 | HTTP `3200`、OTLP `14317/14318` |
| `otel-collector` | OpenTelemetry Collector | OTLP `4317/4318`、Metrics `9464` |
| `alloy` | Docker 日志采集（替代 Promtail） | <http://localhost:12345> |
| `langfuse` | Langfuse v4 完整本地环境 | <http://localhost:3300> |
| `qdrant` | Qdrant 向量数据库 | API `6333/6334`、<http://localhost:6333/dashboard> |
| `ollama` | Ollama 本地模型 | `11434` |

## 管理页面与默认账号

| 组件 | 本地开发默认值 |
|---|---|
| MinIO Console | `minioadmin / dev_minio_password` |
| Grafana | `admin / dev_grafana_password`；仅在空 volume 首次初始化时生效 |
| Prometheus、Alertmanager、Alloy | 默认未启用认证，仅限本机开发 |
| PrometheusAlert | `prometheusalert / dev_prometheus_alert_password` |
| Sentinel | `sentinel / dev_sentinel_password` |
| Apollo | `apollo / admin` |
| XXL-JOB | `admin / 123456` |
| Nacos | 用户名 `nacos`，首次访问控制台时初始化密码 |
| Langfuse | 没有预置 Web 用户，首次访问自行注册；内部 MinIO 为 `minio / dev_langfuse_minio` |
| Elasticsearch/Kibana、Kafka UI、RocketMQ Dashboard | 默认未启用认证，仅限本机开发 |

以上均为本地开发便利配置，来源包括 `.env.example`、初始化数据及模块默认设置；不要用于共享环境或生产环境。

## 常用启动组合

以下只是操作示例，每一行仍是独立模块。

### 普通后端开发

```bash
make up DIR=mysql
make up DIR=redis
make up DIR=minio
```

### Java 微服务

```bash
make up DIR=mysql
make up DIR=redis
make up DIR=nacos
make up DIR=rocketmq
make up DIR=sentinel
make up DIR=xxl-job
```

Nacos 和 Apollo 都能管理配置：简单项目使用 Nacos 即可；需要更完整的配置发布、审计和回滚流程时，可以用 Nacos 做注册中心、Apollo 做配置中心。

### 数据同步与搜索

```bash
make up DIR=mysql
make up DIR=kafka
make up DIR=canal
make up DIR=elasticsearch
make up DIR=clickhouse
```

典型数据流：

```text
MySQL -> Canal -> Kafka -> Elasticsearch / ClickHouse / 业务消费者
```

这只是常见架构示意。当前 Canal 模块提供 Binlog 订阅服务，不会自动把数据写入 Kafka、Elasticsearch 或 ClickHouse；仍需配置 Kafka 模式、Canal Adapter 或业务消费者完成后续投递。

### 可观测性

```bash
make up DIR=loki
make up DIR=tempo
make up DIR=otel-collector
make up DIR=alloy
make up DIR=prometheus
make up DIR=alertmanager
make up DIR=grafana
# 国内通知渠道按需启动：make up DIR=prometheus-alert
```

应用统一发送到 OpenTelemetry Collector：

```dotenv
OTEL_SERVICE_NAME=my-service
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
```

```text
应用 -> OpenTelemetry Collector
       ├── metrics -> Prometheus -> Grafana
       ├── logs    -> Loki       -> Grafana
       └── traces  -> Tempo      -> Grafana

Docker stdout/stderr -> Alloy -> Loki -> Grafana
Prometheus alerts -> Alertmanager -> PrometheusAlert（可选）-> 飞书/钉钉/企微/邮件
```

Promtail 已于 2026-03-02 停止维护，本仓库使用 Grafana Alloy 收集 Docker 容器日志。应用主动发送的 OTLP 日志仍由 OpenTelemetry Collector 接收，两条路径可以按需单独使用。

这些模块仍可单独启动，完整链路的关系如下：

| 模块 | 单独启动时 | 完整链路依赖 |
|---|---|---|
| Loki | 可查询已写入日志 | Collector 向其导出日志 |
| Tempo | 可查询已写入链路 | Collector 向其导出 Trace |
| Collector | 接收 OTLP；下游缺失时日志会报告重试 | Loki、Tempo |
| Alloy | 自动读取 Docker stdout/stderr | Loki |
| Prometheus | 自身可用，Collector 未启动时目标显示 Down | Collector 的 `9464` |
| Alertmanager | UI、静默和分组可独立使用 | Prometheus 向其发送告警 |
| PrometheusAlert | 通知模板可独立配置 | Alertmanager 可选 Webhook |
| Grafana | 页面可用，缺失的数据源会报连接失败 | Prometheus、Loki、Tempo |

它们通过 `dev-backend` 和服务名通信。修改宿主机的 `LOKI_PORT`、`TEMPO_HTTP_PORT` 等映射不会影响容器间地址。

启动后可做基础检查：

```bash
curl -fsS http://localhost:3100/ready
curl -fsS http://localhost:3200/ready
curl -fsS http://localhost:9090/-/ready
curl -fsS http://localhost:9093/-/ready
curl -fsS http://localhost:12345/-/ready
curl -fsS http://localhost:3000/api/health
```

Prometheus 抓取目标：<http://localhost:9090/targets>，告警规则：<http://localhost:9090/alerts>。Grafana 默认登录为 `admin/dev_grafana_password`，已预置 Prometheus、Loki、Tempo 数据源；Trace 跳转日志按 `service.name` 和 Trace ID 过滤。

### AI/LLM 开发

```bash
make up DIR=ollama
make up DIR=qdrant
```

Langfuse 目录内部包含 Web、Worker、PostgreSQL、ClickHouse、Redis 和 MinIO，但整体仍与其他模块隔离，不复用外部数据库。

Ollama 启动后还需要下载模型：

```bash
docker compose -f ollama/compose.yaml exec ollama ollama pull qwen3:8b
docker compose -f ollama/compose.yaml exec ollama ollama list
docker compose -f ollama/compose.yaml exec ollama ollama run qwen3:8b
```

模型保存在 named volume 中，体积可能达到数 GB；`make clean DIR=ollama CONFIRM=1` 会连同模型一起删除。macOS 上运行 Docker 版 Ollama 通常不能直接使用宿主机 Metal，追求本机 GPU 性能时更适合安装原生 Ollama。

Qdrant Dashboard：<http://localhost:6333/dashboard>。API 默认需要 `api-key` 请求头：

```bash
curl -H 'api-key: dev_qdrant_key' http://localhost:6333/collections
```

首次启动 Langfuse 前生成三类独立密钥：

```bash
make init DIR=langfuse
openssl rand -base64 32 # LANGFUSE_NEXTAUTH_SECRET
openssl rand -base64 32 # LANGFUSE_SALT
openssl rand -hex 32    # LANGFUSE_ENCRYPTION_KEY
# 将三个结果分别写入 langfuse/.env
make up DIR=langfuse WAIT_TIMEOUT=600
```

Langfuse 首次初始化数据库可能需要几分钟。`LANGFUSE_ENCRYPTION_KEY` 在已有数据后不能随意更换，否则已加密内容将无法解密。

## 默认开发连接

```text
MySQL:     mysql://app:dev_mysql_password@127.0.0.1:3306/app
Postgres:  postgresql://app:dev_postgres_password@127.0.0.1:5432/app
MongoDB:   mongodb://root:dev_mongo_password@127.0.0.1:27017/app?authSource=admin
Redis:     redis://:dev_redis_password@127.0.0.1:6379/0
Kafka:     localhost:9092
RocketMQ:  NameServer 127.0.0.1:9876，Broker 127.0.0.1:10911
Nacos:     127.0.0.1:8848
```

ClickHouse HTTP 示例：

```bash
curl -u app:dev_clickhouse_password \
  'http://127.0.0.1:8123/?database=app&query=SELECT%201'
```

以上仅是 `.env.example` 中的本地默认值，可以在每个模块的 `.env` 中修改。

Nacos 3 的管理员用户名为 `nacos`，但不再提供默认密码。第一次打开 <http://localhost:18000> 时，按页面提示初始化密码；`.env` 中的 `NACOS_AUTH_IDENTITY_*` 是服务端身份配置，不是控制台登录账号。

RocketMQ 的 Broker 广播地址和 `10909/10911` 端口为本机客户端兼容性做了固定配置，不建议只改宿主机映射。Dashboard 旁的 TCP 代理用于让它访问广播为 `127.0.0.1` 的 Broker。

## 数据库初始化

- `mysql/init/`、`postgres/init/`、`clickhouse/init/` 可以放置业务初始化脚本。
- 初始化目录只会在数据 volume 为空的第一次启动时执行。
- Apollo 和 XXL-JOB 已携带各自的官方初始化 SQL，不需要手工建表。
- 已存在 volume 时修改初始化 SQL 不会自动重新执行，应使用迁移脚本或在确认无数据后删除 volume。

Apollo 默认登录：`apollo/admin`。

XXL-JOB 默认登录：`admin/123456`。登录后应立即修改本地管理员密码。

## Canal 前置配置

Canal 默认通过 `dev-backend` 订阅本仓库的 `mysql:3306`，因此先启动 MySQL：

```bash
make up DIR=mysql
```

确认 MySQL 已开启 Binlog 且格式为 `ROW`：

```sql
SHOW VARIABLES LIKE 'log_bin';
SHOW VARIABLES LIKE 'binlog_format';
```

然后在目标 MySQL 创建 Binlog 账号：

```sql
CREATE USER 'canal'@'%' IDENTIFIED BY 'dev_canal_password';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
FLUSH PRIVILEGES;
```

然后启动：

```bash
make up DIR=canal
```

目标地址和账号可以在 `canal/.env` 中修改。外部 MySQL 可填写容器能访问的域名或 IP；连接失败时先检查 `log_bin=ON`、`binlog_format=ROW`、账号来源地址和 Canal 日志。Canal 的 instance 配置与 TSDB 位点已持久化，升级镜像时应同时检查配置兼容性。

## Nginx 反向代理

默认配置只提供 `/health` 和说明页面。编辑 `nginx/default.conf` 可以代理宿主机应用：

```nginx
location /api/ {
    proxy_pass http://host.docker.internal:8080/;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

修改后执行：

```bash
make restart DIR=nginx
```

如果被代理应用也运行在 Docker 中，推荐让它加入 `dev-backend`，并把 `proxy_pass` 改为服务名，例如 `http://my-api:8080/`。`host.docker.internal` 主要用于访问宿主机进程；原生 Linux 上，如果该进程只监听 `127.0.0.1`，容器仍无法访问它。

## 数据与升级

查看模块 volume：

```bash
docker volume ls --filter name=dev-mysql
docker system df
```

停止模块不会删除数据：

```bash
make down DIR=mysql
```

永久删除该模块的数据：

```bash
make clean DIR=mysql CONFIRM=1
```

数据库镜像不要直接跨 major 版本修改标签后启动。先导出数据、阅读对应升级文档，再升级并验证。

其他持久化配置也有相同约束：

- Grafana 管理员密码只在空 volume 首次初始化时生效。
- Qdrant 存在数据时应按 minor 版本逐级升级，不要跨多个 minor 直接跳转。
- Langfuse 已有数据后不要更换 `LANGFUSE_ENCRYPTION_KEY`。
- Ollama 模型存放在 volume 中，执行 `clean` 会删除已下载模型。

## 常见问题

### Docker daemon 未运行

```text
failed to connect to the docker API
```

先启动 Docker Desktop/Engine，再执行 `make doctor`。

### 拉取镜像出现 EOF 或长时间不动

如果错误信息中出现第三方镜像代理域名（例如 `hub-mirror.c.163.com`），通常是代理在传输大镜像层时中断，并非 Compose 配置错误。先查看 Docker 当前配置的代理：

```bash
docker info | sed -n '/Registry Mirrors/,+5p'
```

可以先重试单个模块：

```bash
make pull DIR=langfuse
make up DIR=langfuse WAIT_TIMEOUT=600
```

若同一层反复 EOF，应在 Docker Desktop 的 Engine 配置中移除或更换不稳定的 `registry-mirrors`，重启 Docker Desktop 后再拉取。不要用 `docker system prune --volumes` 处理网络下载问题，它不会修复代理，反而可能删除本地开发数据。

### 端口已被占用

复制并修改模块的 `.env`：

```bash
make init DIR=elasticsearch
# 修改 elasticsearch/.env 中的 ELASTIC_PORT 或 KIBANA_PORT
make up DIR=elasticsearch
```

Apollo Config Service 的宿主机端口固定为 `8080`，这是本地服务发现地址的一部分，不建议修改。Nacos Console 已改为 `18000`，因此二者可以同时运行。

### 容器一直不健康

```bash
make ps DIR=mysql
make logs DIR=mysql
make config DIR=mysql
```

重点检查密码是否与已有 volume 中的旧密码不一致。数据库初始化变量只在首次创建 volume 时生效。

### Elasticsearch 在 Linux 启动失败

如果日志提示虚拟内存映射数量不足，在宿主机执行：

```bash
sudo sysctl -w vm.max_map_count=1048576
```

默认堆内存为 1 GB，可在 `elasticsearch/.env` 调整 `ELASTIC_HEAP`；同时给 Docker 留出高于堆内存的额外空间。

### Apple Silicon 上 XXL-JOB 较慢

XXL-JOB 3.4.0 上游镜像仅提供 AMD64，Compose 已显式声明 `linux/amd64`。首次拉取和启动时需要模拟，速度慢于原生 ARM64 镜像。

## 安全说明

- 所有端口默认仅监听本机，但关闭认证的 Elasticsearch 等模块仍不能用于生产。
- `.env` 已被 Git 忽略；提交前仍建议用 `git status` 检查是否包含密钥。
- 不要将示例密码用于共享开发机、测试服务器或生产环境。
- Apollo Config/Admin、RocketMQ Dashboard、Sentinel Dashboard 等管理入口不要暴露到公网。
