# FWWB 北部赛区决赛 - 文档智能填表项目

基于 RAGFlow 的智能填表系统，支持 Word/Excel 模板自动填充、多文档聚合、规则+LLM 混合解析。

## 前置条件

| 项目 | 要求 |
|------|------|
| 操作系统 | Ubuntu 20.04+（推荐 22.04/24.04） |
| Docker | 24.0+ |
| Docker Compose | v2.0+ |
| 内存 | ≥ 16GB |
| 磁盘 | ≥ 30GB |

## 一键部署（推荐）

```bash
git clone https://github.com/LSYY1/fwwbb-newwin.git
cd fwwbb-newwin
chmod +x deploy.sh
./deploy.sh
```

或手动执行：

```bash
git clone https://github.com/LSYY1/fwwbb-newwin.git
cd fwwbb-newwin/docker
cp .env.example .env
docker compose --profile cpu pull
docker compose --profile cpu up -d
```

## 访问地址

| 服务 | 地址 |
|------|------|
| 前端 | http://localhost:9222 |
| 智能填表 | http://localhost:9222/#/form-fill |
| API | http://localhost:9380 |

## 首次使用

1. 注册并登录
2. 右上角头像 → **模型提供商**，配置大模型 API Key（如通义千问、OpenAI 等）
3. 左侧 **智能填表** → 新建任务 → 上传数据源与模板 → 开始处理

## Docker 镜像

| 镜像 | 说明 |
|------|------|
| `ghcr.io/lsyy1/ragflow-fwwb:2.0.0` | 决赛版主服务（推荐，与 GitHub 同账号拉取） |
| `lsyy1/ragflow-fwwb:2.0.0` | Docker Hub 镜像（若已同步） |

```bash
# 拉取镜像（公开包无需登录；私有包需先 docker login ghcr.io -u lsyy1）
docker pull ghcr.io/lsyy1/ragflow-fwwb:2.0.0
```

## 常用命令

```bash
cd docker
docker compose ps
docker compose logs -f ragflow-cpu
docker compose down
docker compose restart
```

## 初赛项目

静态 Demo 与说明见：[fwwb-rag-file](https://github.com/lsyy1/fwwb-rag-file)

## License

MIT
