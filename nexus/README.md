# Nexus Repository Community Edition 本地使用

```bash
make up DIR=nexus WAIT_TIMEOUT=900
docker compose -f nexus/compose.yaml exec nexus cat /nexus-data/admin.password
```

打开 <http://localhost:18086>，用户名为 `admin`，初始密码由上面的命令读取。

Nexus 可作为 Maven、npm、PyPI、NuGet、Docker、Helm、Raw 等制品的 Hosted/Proxy/Group 仓库。默认只暴露管理和 HTTP 仓库端口；创建 Docker Repository 后如需独立 Connector 端口，应在 Compose 和 `.env` 中按实际端口显式增加映射。

全部制品和配置保存在 `nexus_data` volume。升级前必须备份，并阅读数据库和 Java 版本迁移说明；不要直接跨多个版本替换镜像。
