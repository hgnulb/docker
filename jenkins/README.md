# Jenkins LTS 本地使用

```bash
make up DIR=jenkins WAIT_TIMEOUT=600
docker compose -f jenkins/compose.yaml exec jenkins \
  cat /var/jenkins_home/secrets/initialAdminPassword
```

打开 <http://localhost:8084>，输入命令输出的初始密码，然后按向导安装推荐插件并创建管理员。

- Web：<http://localhost:8084>
- 入站 Agent：`127.0.0.1:50000`
- 其他 `dev-backend` 容器访问 Jenkins：`http://jenkins:8080`
- Jenkins Home：`jenkins_home` volume

官方镜像不包含 Docker CLI。本模块也没有挂载 `/var/run/docker.sock`：直接挂载会让 Jenkins 内任务获得近似宿主机 root 的 Docker 控制权。需要构建容器镜像时，推荐配置独立构建 Agent，或按 Jenkins 官方文档配置启用 TLS 的 Docker-in-Docker 服务。

插件、任务、凭据和构建记录都保存在 `jenkins_home`。升级前应备份该 volume，并检查 Jenkins Core、Java 和已安装插件的兼容性。不要使用浮动的 `latest` 标签跨版本升级。
