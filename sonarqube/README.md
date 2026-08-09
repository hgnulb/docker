# SonarQube Community Build 本地使用

```bash
make up DIR=sonarqube WAIT_TIMEOUT=900
```

打开 <http://localhost:19001>，首次登录为 `admin / admin`，系统会要求立即修改密码。

该模块使用独立 PostgreSQL，不复用仓库根级 PostgreSQL。SonarQube 数据、插件、日志和数据库分别持久化到 named volumes。

Linux 启动前可能需要设置：

```bash
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
```

Jenkins 可安装 SonarQube Scanner 插件，GitLab CI 可直接运行对应 Scanner。生产环境还需 TLS、外部数据库备份、认证集成和项目权限配置。
