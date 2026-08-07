# 所有模块统一通过 DIR=<目录名> 操作，例如：make up DIR=redis
.DEFAULT_GOAL := help

DIR ?= mysql
WAIT_TIMEOUT ?= 300

COMPONENTS := $(sort $(patsubst %/compose.yaml,%,$(wildcard */compose.yaml)))
# 在执行 Compose 的那一刻再选择配置文件。这样首次 `make up` 由 init 创建 .env 后，
# 同一次命令就会使用新文件，而不是 Make 预先解析到的 .env.example。
COMPOSE = env_file="$(DIR)/.env"; \
	if test ! -f "$$env_file"; then env_file="$(DIR)/.env.example"; fi; \
	docker compose --env-file "$$env_file" -f "$(DIR)/compose.yaml"

.PHONY: help list doctor network check init up down restart ps logs pull config clean validate

help: ## 显示帮助
	@echo "用法: make <命令> DIR=<模块目录>"
	@echo
	@echo "常用命令:"
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z_-]+:.*## / {printf "  %-10s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo
	@echo "示例: make up DIR=redis"

list: ## 列出所有可用模块
	@printf '%s\n' $(COMPONENTS)

doctor: ## 检查 Docker 与 Compose 环境
	@command -v docker >/dev/null || { echo "错误: 未找到 docker 命令"; exit 1; }
	@docker compose version
	@docker info >/dev/null || { echo "错误: Docker daemon 未运行，请先启动 Docker Desktop/Engine"; exit 1; }
	@echo "Docker 环境正常"

network: ## 创建跨模块通信网络（已存在则跳过）
	@docker network inspect "dev-backend" >/dev/null 2>&1 || { \
		docker network create "dev-backend" >/dev/null; \
		echo "已创建 Docker 网络 dev-backend"; \
	}

check: ## 检查 DIR 指向的模块
	@test -d "$(DIR)" || { echo "错误: 模块目录不存在: $(DIR)"; exit 1; }
	@test -f "$(DIR)/compose.yaml" || { echo "错误: 缺少 $(DIR)/compose.yaml"; exit 1; }
	@test -f "$(DIR)/.env" || test -f "$(DIR)/.env.example" || { echo "错误: 缺少 $(DIR)/.env 或 .env.example"; exit 1; }

init: check ## 首次创建模块的 .env（已存在则不覆盖）
	@if test ! -f "$(DIR)/.env"; then \
		cp "$(DIR)/.env.example" "$(DIR)/.env"; \
		echo "已创建 $(DIR)/.env，请按需修改"; \
	else \
		echo "保留已有 $(DIR)/.env"; \
	fi

up: network init ## 启动指定模块并等待已配置健康检查的服务
	$(COMPOSE) up -d --wait --wait-timeout $(WAIT_TIMEOUT)

down: check ## 停止指定模块，保留数据
	$(COMPOSE) down

restart: check ## 仅重启现有容器，不应用 .env/Compose 变更
	$(COMPOSE) restart

ps: check ## 查看指定模块状态
	$(COMPOSE) ps

logs: check ## 持续查看最近 200 行日志
	$(COMPOSE) logs -f --tail=200

pull: check ## 拉取指定模块镜像
	$(COMPOSE) pull

config: check ## 输出变量展开后的 Compose 配置
	$(COMPOSE) config

clean: check ## 删除指定模块及其数据卷（需要 CONFIRM=1）
	@test "$(CONFIRM)" = "1" || { \
		echo "拒绝删除数据卷。确认后执行: make clean DIR=$(DIR) CONFIRM=1"; \
		exit 1; \
	}
	$(COMPOSE) down --volumes --remove-orphans

validate: ## 校验全部 Compose 文件
	@set -e; for dir in $(COMPONENTS); do \
		echo "校验 $$dir/compose.yaml"; \
		docker compose --env-file "$$dir/.env.example" -f "$$dir/compose.yaml" config --quiet; \
	done
	@echo "全部 $(words $(COMPONENTS)) 个模块校验通过"
