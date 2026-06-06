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
echo "⏳ 等待服务就绪（约 2~5 分钟）..."
WEB_PORT="${SVR_WEB_HTTP_PORT:-9222}"
API_PORT="${SVR_HTTP_PORT:-9380}"
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

echo ""
if [ "${ready}" -eq 1 ]; then
  echo "✅ 部署完成！"
else
  echo "⚠️  容器已启动，但前端尚未完全就绪，请稍后再访问或查看日志。"
fi

echo ""
echo "  前端:     http://localhost:${WEB_PORT}"
echo "  数据池:   http://localhost:${WEB_PORT}/#/data-pool"
echo "  智能填表: http://localhost:${WEB_PORT}/#/form-fill"
echo "  API:      http://localhost:${API_PORT}"
echo ""
echo "  首次使用: 注册登录 → 头像 → 模型提供商 → 配置 API Key"
echo ""
echo "  查看状态: cd docker && docker compose ps"
echo "  查看日志: cd docker && docker compose logs -f ragflow-cpu"
