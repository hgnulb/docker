# Apache Airflow 本地使用

```bash
make up DIR=airflow WAIT_TIMEOUT=600
make logs DIR=airflow
```

打开 <http://localhost:18085>。`airflow standalone` 会在首次启动时初始化数据库并在日志中输出管理员账号和随机密码，可用以下命令再次查看：

```bash
docker compose -f airflow/compose.yaml exec airflow \
  cat /opt/airflow/simple_auth_manager_passwords.json.generated
```

DAG 文件放入 `airflow/dags/`。Airflow 已加入 `dev-backend`，任务可访问仓库内其他服务。

这是官方 standalone 本地体验模式，元数据、日志和配置保存在 `airflow_data` volume 中。生产环境应使用外部 PostgreSQL、分布式 Executor、独立 Scheduler/API Server/Worker 和 Secrets Backend。
