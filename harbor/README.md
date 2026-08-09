# Harbor

Harbor 是 CNCF 毕业项目，用于私有镜像仓库、制品管理、复制、签名与漏洞扫描。本目录使用 Harbor 官方在线安装器 `v2.14.4`，而不是维护一份容易与上游漂移的手写 Compose。

Harbor 官方安装过程会现场生成多服务 Compose、内部配置、共享密钥和私钥，因此生成内容放在 Git 忽略的 `.runtime/` 中，不提交到仓库。

## 安装并启动

```bash
./harbor/install.sh
```

默认入口：<http://harbor.localhost:18087>，管理员为 `admin / dev_harbor_admin_password`。首次使用前应通过环境变量替换密码：

```bash
HARBOR_ADMIN_PASSWORD="$(openssl rand -base64 24)" \
HARBOR_DB_PASSWORD="$(openssl rand -base64 24)" \
./harbor/install.sh
```

可覆盖 `HARBOR_VERSION`、`HARBOR_HOSTNAME` 和 `HARBOR_HTTP_PORT`。脚本默认启用 Trivy 漏洞扫描。

只下载官方安装器并生成 `harbor.yml`、暂不启动时：

```bash
HARBOR_INSTALL=false ./harbor/install.sh
```

## 日常管理

```bash
cd harbor/.runtime/harbor
docker compose ps
docker compose logs -f
docker compose down
docker compose up -d
```

数据、日志、安装器和生成配置都保存在 `harbor/.runtime/`。如需升级，先备份该目录及镜像仓库数据，再按照 Harbor 官方升级文档操作；不要直接修改版本后覆盖已有实例。

Harbor 不参与根目录的 `make list`、`make up` 和 `make validate`，因为它的 `docker-compose.yml` 必须由官方 `prepare` 根据当前版本和现场密钥生成。

Harbor 官方镜像目前主要面向 AMD64；Apple Silicon 上由 Docker Desktop 模拟运行，启动和扫描速度会慢于原生 ARM64 组件。
