#!/usr/bin/env sh
set -eu

HARBOR_VERSION="${HARBOR_VERSION:-v2.14.4}"
HARBOR_HTTP_PORT="${HARBOR_HTTP_PORT:-18087}"
HARBOR_HOSTNAME="${HARBOR_HOSTNAME:-harbor.localhost}"
HARBOR_ADMIN_PASSWORD="${HARBOR_ADMIN_PASSWORD:-dev_harbor_admin_password}"
HARBOR_DB_PASSWORD="${HARBOR_DB_PASSWORD:-dev_harbor_db_password}"

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
runtime_dir="$script_dir/.runtime"
archive_name="harbor-online-installer-${HARBOR_VERSION}.tgz"
download_url="https://github.com/goharbor/harbor/releases/download/${HARBOR_VERSION}/${archive_name}"

command -v docker >/dev/null 2>&1 || { echo "错误: 未找到 docker" >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "错误: 未找到 curl" >&2; exit 1; }
docker info >/dev/null 2>&1 || { echo "错误: Docker daemon 未运行" >&2; exit 1; }

mkdir -p "$runtime_dir"
if [ ! -f "$runtime_dir/harbor/install.sh" ]; then
  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' EXIT INT TERM
  echo "下载 Harbor ${HARBOR_VERSION} 官方在线安装器..."
  curl --fail --location --retry 3 --output "$tmp_dir/$archive_name" "$download_url"
  tar -xzf "$tmp_dir/$archive_name" -C "$runtime_dir"
fi

harbor_dir="$runtime_dir/harbor"
data_dir="$runtime_dir/data"
log_dir="$runtime_dir/log"
mkdir -p "$data_dir" "$log_dir"

awk \
  -v hostname="$HARBOR_HOSTNAME" \
  -v port="$HARBOR_HTTP_PORT" \
  -v admin_password="$HARBOR_ADMIN_PASSWORD" \
  -v db_password="$HARBOR_DB_PASSWORD" \
  -v data_dir="$data_dir" \
  -v log_dir="$log_dir" '
  /^hostname:/ { print "hostname: " hostname; next }
  !http_port_done && /^  port: 80$/ { print "  port: " port; http_port_done=1; next }
  /^harbor_admin_password:/ { print "harbor_admin_password: " admin_password; next }
  /^  password: root123$/ { print "  password: " db_password; next }
  /^data_volume:/ { print "data_volume: " data_dir; next }
  /^    location: \/var\/log\/harbor$/ { print "    location: " log_dir; next }
  { print }
' "$harbor_dir/harbor.yml.tmpl" > "$harbor_dir/harbor.yml"

if [ "${HARBOR_INSTALL:-true}" != "true" ]; then
  echo "Harbor 配置已生成: $harbor_dir/harbor.yml"
  exit 0
fi

echo "使用官方安装器生成配置并启动 Harbor（含 Trivy）..."
cd "$harbor_dir"
./install.sh --with-trivy

echo "Harbor 已启动: http://${HARBOR_HOSTNAME}:${HARBOR_HTTP_PORT}"
echo "管理员: admin"
