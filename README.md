# FWWB 北部赛区决赛 · 文档智能填表系统

> 基于 [RAGFlow](https://github.com/infiniflow/ragflow) 的多源文档智能填表方案：用**自然语言描述需求**，自动将 Word / Excel / TXT / MD 等数据源填入模板，支持多文档聚合与规则 + 大模型混合解析。

[![Docker Image](https://img.shields.io/badge/docker-ghcr.io%2Flsyy1%2Fragflow--fwwb%3A2.0.0-blue)](https://github.com/lsyy1/fwwbb-newwin/pkgs/container/ragflow-fwwb)

---

## 项目简介

本仓库为**决赛部署包**，包含 Docker Compose 编排、环境配置与一键启动脚本。完整应用镜像已打包为 `ghcr.io/lsyy1/ragflow-fwwb:2.0.0`，评委/用户只需安装 Docker 即可拉取运行。

**核心能力**

- 多格式数据源：`.docx` / `.xlsx` / `.txt` / `.md`
- 模板填表：Word、Excel 统一逻辑（仅表头模板也可自动追加数据行）
- 自然语言需求：中文描述统计口径、年份、地区，无需编写脚本
- 场景化解析：人口就业、多城市 GDP、区域对比、国考职位统计等
- 规则优先 + LLM 兜底：兼顾准确率与复杂场景泛化

---

## 系统页面

| 页面 | 路径 | 功能 |
|------|------|------|
| **数据池** | `/#/data-pool` | 创建数据池、上传源文件、自动解析建索引，一次准备、多次复用 |
| **智能填表** | `/#/form-fill` | 选择就绪数据池 → 上传模板 → 填写用户需求 → 一键处理 → 下载结果 |

**推荐使用流程**

```
配置模型 → 数据池上传文档 → 智能填表选池填模板 → 下载结果
```

---

## 前置条件

| 项目 | 要求 |
|------|------|
| 操作系统 | Ubuntu 20.04+（推荐 22.04 / 24.04） |
| Docker | 24.0+ |
| Docker Compose | v2.0+ |
| 内存 | ≥ 16GB |
| 磁盘 | ≥ 30GB |

---

## 一键部署

```bash
git clone https://github.com/lsyy1/fwwbb-newwin.git
cd fwwbb-newwin
chmod +x deploy.sh
./deploy.sh
```

脚本将自动：复制 `.env` → 拉取镜像与依赖 → 启动 MySQL / Elasticsearch / Redis / MinIO / RAGFlow。

### 手动部署

```bash
git clone https://github.com/lsyy1/fwwbb-newwin.git
cd fwwbb-newwin/docker
cp .env.example .env
docker compose --profile cpu pull
docker compose --profile cpu up -d
```

首次启动约需 **2～3 分钟**，可通过以下命令查看状态：

```bash
cd docker
docker compose ps
docker compose logs -f ragflow-cpu
```

---

## 访问地址

| 服务 | 地址 |
|------|------|
| 前端首页 | http://localhost:9222 |
| 数据池 | http://localhost:9222/#/data-pool |
| 智能填表 | http://localhost:9222/#/form-fill |
| 后端 API | http://localhost:9380 |

---

## 首次使用指南

### 1. 配置大模型（首次必做）

1. 打开 http://localhost:9222 ，注册并登录
2. 点击右上角头像 → **模型提供商**
3. 配置所使用的大模型 API Key（如通义千问、OpenAI 等）

> API Key 由用户自行配置，**不包含在镜像内**。

### 2. 数据池：准备数据源

1. 进入 **数据池** 页面
2. 新建数据池并命名（如「人口就业四文档」）
3. 上传源文件（支持 `.docx` / `.xlsx` / `.txt` / `.md`）
4. 等待状态变为 **就绪**

### 3. 智能填表：生成结果

1. 进入 **智能填表** 页面
2. 选择已就绪的数据池
3. 上传 Word 或 Excel 模板
4. 在「用户需求」中描述填表意图，例如：

   > 从四个文档中提取各地区的常住人口、就业人员数、城镇化率等人口与就业指标

5. 点击 **开始处理**，等待完成后 **下载结果**

---

## 演示案例参考

| 场景 | 用户需求示例 | 模板表头示例 |
|------|-------------|-------------|
| 人口就业 | 从四个文档中提取各地区人口与就业指标 | 地区、常住人口、户籍人口、城镇化率、就业人员数 |
| 多城市 GDP | 从东莞和南京统计公报提取 2024 年 GDP 与三次产业 | 城市、地区生产总值、第一/二/三产业增加值、常住人口 |
| 国考职位 | 统计江苏省各地区职位数量、学历与专业分布 | 地区、职位总数、本科及以上、计算机类等 |

---

## Docker 镜像

| 镜像 | 说明 |
|------|------|
| `ghcr.io/lsyy1/ragflow-fwwb:2.0.0` | 决赛版主服务（推荐） |
| `lsyy1/ragflow-fwwb:2.0.0` | Docker Hub 同步版（如有） |

```bash
docker pull ghcr.io/lsyy1/ragflow-fwwb:2.0.0
```

若镜像为私有包，需先登录：

```bash
echo "<YOUR_GITHUB_TOKEN>" | docker login ghcr.io -u lsyy1 --password-stdin
```

---

## 技术栈

| 分类 | 技术 |
|------|------|
| 前端 | React 18、TypeScript、Vite、Tailwind CSS |
| 后端 | Python Quart、RAGFlow |
| 智能 | 大语言模型 + 规则解析引擎 |
| 文档 | python-docx、openpyxl |
| 存储 | MySQL、Elasticsearch、Redis、MinIO |
| 部署 | Docker、Docker Compose |

---

## 仓库结构

```
fwwbb-newwin/
├── deploy.sh              # 一键部署脚本
├── docker/
│   ├── .env.example       # 环境配置模板
│   ├── docker-compose.yml
│   ├── docker-compose-base.yml
│   ├── entrypoint.sh
│   └── nginx/
└── README.md
```

---

## 常见问题

**Q：端口被占用怎么办？**  
修改 `docker/.env` 中的 `SVR_WEB_HTTP_PORT`（默认 9222）或 `SVR_HTTP_PORT`（默认 9380）。

**Q：内存不足？**  
建议服务器 ≥ 16GB；可在 `.env` 中调整 `MEM_LIMIT`。

**Q：镜像拉取失败？**  
检查网络，或配置 Docker 镜像加速；确认 GHCR 包已设为 Public。

**Q：填表结果不准确？**  
检查数据池是否包含正确源文件、用户需求是否描述清晰、大模型是否配置正常。
