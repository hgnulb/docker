## Docker Compose

推荐文件路径：`${你的工作目录}/docker/mysql/docker-compose.yml` 后续使用 docker 管理的服务都可以集中在 `${你的工作目录}/docker` 下方便管理

## 启动服务
docker-compose up -d

docker-compose down -v

## 查看服务启动情况

docker ps -a

## 停止容器、服务

docker stop <容器ID 或 名称>

## 删除容器、服务

docker rm -f <容器ID 或 名称>