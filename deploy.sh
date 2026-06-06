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

echo ""
echo "🚀 拉取镜像（首次可能较久）..."
docker compose --profile cpu pull

echo ""
echo "🚀 启动服务..."
docker compose --profile cpu up -d

echo ""
echo "⏳ 等待服务就绪（约 2~3 分钟）..."
sleep 30

echo ""
echo "✅ 部署完成！"
echo ""
echo "  前端:     http://localhost:9222"
echo "  智能填表: http://localhost:9222/#/form-fill"
echo "  API:      http://localhost:9380"
echo ""
echo "  查看状态: cd docker && docker compose ps"
echo "  查看日志: cd docker && docker compose logs -f ragflow-cpu"
