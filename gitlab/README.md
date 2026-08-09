# GitLab CE 本地使用

GitLab 是仓库中资源占用最大的模块之一。官方单节点基线为 8 vCPU、16 GB 内存，受限环境至少约 8 GB；首次启动通常需要数分钟。建议单独启动：

```bash
make init DIR=gitlab
# 修改 gitlab/.env 中的 root 密码
make up DIR=gitlab WAIT_TIMEOUT=900
```

- Web：<http://gitlab.localhost:8929>
- 默认管理员：`root / dev_gitlab_root_password`，以 `.env` 实际值为准
- SSH Clone：`ssh://git@localhost:2224/<namespace>/<project>.git`
- 其他 `dev-backend` 容器：`http://gitlab:8929`

如果 `gitlab.localhost` 在本机不能解析，可访问 <http://localhost:8929>，或将 `127.0.0.1 gitlab.localhost` 加入 hosts 文件。

初始密码只在空数据卷第一次配置时生效。已有 volume 后修改 `.env` 不会修改 root 密码，应在 GitLab 页面或 Rails Console 中修改。

配置、日志和业务数据分别保存在 `gitlab_config`、`gitlab_logs`、`gitlab_data` volumes 中。升级必须阅读 GitLab 升级路径，不能随意跨 required upgrade stops；升级前应同时备份配置、数据库和仓库数据。

本模块关闭了内置 Prometheus，并降低 Puma/Sidekiq 并发以适应个人本地开发，不代表生产部署配置。GitLab Runner 未默认加入；需要实际运行 CI Job 时再单独注册 Runner，避免闲置资源开销。
