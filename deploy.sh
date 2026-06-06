#!/bin/bash
# FWWB 决赛一键部署：拉取镜像并启动全套服务（MySQL/ES/Redis/MinIO/RAGFlow）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="${SCRIPT_DIR}/docker"

echo "=========================================="
echo "  FWWB 文档智能填表 - 一键部署"
echo "=========================================="

if ! command -v docker >/dev/null 2>&1; then
  echo "❌ 未检测到 Docker，请先安装: https://docs.docker.com/engine/install/ubuntu/"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "❌ 未检测到 Docker Compose v2"
  exit 1
fi

cd "${DOCKER_DIR}"

if [ ! -f .env ]; then
  echo "📄 复制配置文件 .env.example → .env"
  cp .env.example .env
fi

# 从 .env 加载 COMPOSE_PROFILES（elasticsearch,cpu）
set -a
# shellcheck disable=SC1091
source .env
set +a

echo ""
echo "🚀 拉取镜像（首次可能较久，约 5GB 应用镜像 + ES/MySQL 等）..."
docker compose pull

echo ""
echo "🚀 启动服务..."
docker compose up -d

echo ""
echo "📋 容器状态:"
docker compose ps

WEB_PORT="${SVR_WEB_HTTP_PORT:-9222}"
API_PORT="${SVR_HTTP_PORT:-9380}"

echo ""
echo "🔌 端口监听检查:"
if ss -tlnp 2>/dev/null | grep -q ":${WEB_PORT} "; then
  ss -tlnp 2>/dev/null | grep ":${WEB_PORT} " || true
else
  echo "  ⚠️  未检测到 0.0.0.0:${WEB_PORT} 监听，请执行: cd docker && docker compose logs ragflow-cpu --tail 80"
fi

echo ""
echo "⏳ 等待服务就绪（约 2~5 分钟）..."
ready=0
for i in $(seq 1 60); do
  sleep 5
  code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "http://127.0.0.1:${WEB_PORT}/" 2>/dev/null || echo "000")
  if [ "${code}" != "000" ] && [ "${code}" != "502" ] && [ "${code}" != "503" ]; then
    ready=1
    break
  fi
  echo "  等待中... (${i}/60)"
done

# 获取本机局域网 IP（供笔记本访问）
LAN_IP=""
if command -v hostname >/dev/null 2>&1; then
  LAN_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
fi
if [ -z "${LAN_IP}" ]; then
  LAN_IP="<服务器IP>"
fi

echo ""
if [ "${ready}" -eq 1 ]; then
  echo "✅ 部署完成！"
else
  echo "⚠️  容器已启动，但前端尚未完全就绪，请稍后再访问或查看日志。"
fi

echo ""
echo "  本机访问:"
echo "    前端:     http://127.0.0.1:${WEB_PORT}"
echo "    数据池:   http://127.0.0.1:${WEB_PORT}/#/data-pool"
echo "    智能填表: http://127.0.0.1:${WEB_PORT}/#/form-fill"
echo ""
echo "  局域网/远程访问（笔记本请用服务器 IP，不要用 localhost）:"
echo "    前端:     http://${LAN_IP}:${WEB_PORT}"
echo "    数据池:   http://${LAN_IP}:${WEB_PORT}/#/data-pool"
echo "    智能填表: http://${LAN_IP}:${WEB_PORT}/#/form-fill"
echo "    API:      http://${LAN_IP}:${API_PORT}"
echo ""
echo "  若外网/笔记本无法访问，请在服务器放行防火墙:"
echo "    sudo ufw allow ${WEB_PORT}/tcp"
echo "    sudo ufw allow ${API_PORT}/tcp"
echo ""
echo "  首次使用: 注册登录 → 头像 → 模型提供商 → 配置 API Key"
echo ""
echo "  查看状态: cd docker && docker compose ps"
echo "  查看日志: cd docker && docker compose logs -f ragflow-cpu"
