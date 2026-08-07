# XXL-JOB 本地使用

该模块包含 XXL-JOB Admin 和独立 MySQL，初始化表来自 XXL-JOB 3.4.0 上游。

```bash
make up DIR=xxl-job
```

- 管理页面：<http://localhost:8083/xxl-job-admin>
- 默认登录：`admin/123456`
- 默认 Access Token：`dev_xxl_job_token`

Spring Boot 执行器常用配置：

```yaml
xxl:
  job:
    admin:
      addresses: http://127.0.0.1:8083/xxl-job-admin
    accessToken: dev_xxl_job_token
```

如果执行器也运行在 Docker Desktop 中，把地址改为 `http://host.docker.internal:8083/xxl-job-admin`。原生 Linux 需要在执行器 Compose 中增加 `host.docker.internal:host-gateway`，或让执行器使用可路由的宿主机地址。

上游 3.4.0 镜像仅提供 AMD64，Apple Silicon 会通过 Docker Desktop 模拟运行。
