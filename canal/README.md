# Canal 本地使用

Canal 通过 MySQL Binlog 捕获数据变化。默认通过共享网络连接本仓库的 `mysql:3306`，目标实例名为 `example`。

## MySQL 前置条件

先启动 MySQL，并确认 Binlog 已开启且格式为 `ROW`：

```bash
make up DIR=mysql
```

```sql
SHOW VARIABLES LIKE 'log_bin';
SHOW VARIABLES LIKE 'binlog_format';
```

然后创建复制账号：

```sql
CREATE USER 'canal'@'%' IDENTIFIED BY 'dev_canal_password';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
FLUSH PRIVILEGES;
```

如果订阅其他 MySQL，修改 `canal/.env`：

```dotenv
CANAL_MYSQL_HOST=db.example.internal
CANAL_MYSQL_PORT=3306
CANAL_MYSQL_USER=canal
CANAL_MYSQL_PASSWORD=dev_canal_password
```

该地址必须能从 Canal 容器内访问。MySQL 运行在宿主机时，Docker Desktop 可使用 `host.docker.internal`；原生 Linux 建议使用可路由的宿主机地址，或为 Canal 服务显式配置 `host-gateway`。

## 启动与排障

```bash
make up DIR=canal
make logs DIR=canal
```

Canal Server 端口为 `11111`。连接失败时依次检查：MySQL 是否运行、`log_bin=ON`、`binlog_format=ROW`、账号权限、密码和容器网络。

`canal_conf` volume 保存 instance 配置与 TSDB 位点，避免容器重建后从旧位置重复消费。更换 Canal 版本时应先备份并检查配置兼容性。
