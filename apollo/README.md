# Apollo 本地使用

该模块采用 Apollo 官方维护的 quick-start 结构，包含 Portal、Config Service、Admin Service 和独立 MySQL。

## 启动

```bash
make init DIR=apollo
make up DIR=apollo
```

| 功能 | 地址 |
|---|---|
| Portal | <http://localhost:8070> |
| Config Service | <http://localhost:8080> |
| Admin Service | <http://localhost:8090> |
| MySQL | `127.0.0.1:13306` |

默认 Portal 登录为 `apollo/admin`。

Config Service 的宿主机端口保持为 `8080`，因为它会参与 Apollo 客户端的服务发现。需要同时运行 Nacos 时，Nacos Console 使用的是 `18000`，不会冲突。

## 初始化数据

`sql/` 中的两个文件来自 Apollo quick-start 上游：

- `01-apolloconfigdb.sql`：配置和发布数据。
- `02-apolloportaldb.sql`：Portal 用户、权限和系统设置。

它们只在 MySQL volume 第一次创建时执行。修改 SQL 后不会自动更新已有数据库。

永久重置本地 Apollo：

```bash
make clean DIR=apollo CONFIRM=1
make up DIR=apollo
```

该命令会删除所有 Apollo 配置与发布记录。
