# FWWB 北部赛区决赛 · 文档智能填表系统

> 基于 [RAGFlow](https://github.com/infiniflow/ragflow) 的多源文档智能填表方案：用**自然语言描述需求**，自动将 Word / Excel / TXT / MD 等数据源填入模板，支持多文档聚合与规则 + 大模型混合解析。

[![Docker Image](https://img.shields.io/badge/docker-ghcr.io%2Flsyy1%2Fragflow--fwwb%3A2.0.0-blue)](https://github.com/lsyy1/fwwbb-newwin/pkgs/container/ragflow-fwwb)

---

## 项目简介

本仓库为**决赛部署包**，包含 Docker Compose 编排、环境配置与一键启动脚本。完整应用镜像已打包为 `ghcr.io/lsyy1/ragflow-fwwb:2.0.0`（**GHCR Public**，可匿名拉取），评委/用户只需安装 Docker 即可运行。

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
| 网络 | 可访问 GitHub（拉代码）与 ghcr.io（拉镜像） |

---

## 部署架构

一键部署会启动以下容器：

| 容器 | 作用 |
|------|------|
| `ragflow-cpu` | 前端 + 后端 API + Admin（端口 9222 / 9380 等） |
| `mysql` | 业务数据库 |
| `es01` | Elasticsearch 文档检索 |
| `redis` | 缓存 |
| `minio` | 对象存储 |

前端端口默认 **9222**，已绑定 `0.0.0.0`，支持局域网通过服务器 IP 访问。

---

## 部署操作流程

### 方式一：一键部署（推荐）

在**全新 Ubuntu 服务器**上执行：

```bash
# 1. 克隆部署仓库
git clone https://github.com/lsyy1/fwwbb-newwin.git
cd fwwbb-newwin

# 2. 一键启动（自动复制 .env、拉镜像、启动全套服务）
chmod +x deploy.sh
./deploy.sh
```

`deploy.sh` 会自动完成：

1. 检查 Docker / Docker Compose
2. 复制 `docker/.env.example` → `docker/.env`（若不存在）
3. 读取 `COMPOSE_PROFILES=elasticsearch,cpu` 启动 ES + CPU 版 RAGFlow
4. `docker compose pull` 拉取镜像（应用镜像约 5GB，首次较久）
5. `docker compose up -d` 启动全部服务
6. 轮询等待前端就绪，并输出本机 / 局域网访问地址

### 方式二：手动部署

```bash
git clone https://github.com/lsyy1/fwwbb-newwin.git
cd fwwbb-newwin/docker

cp .env.example .env          # 首次必做
docker compose pull           # 拉取镜像
docker compose up -d          # 启动（profile 已在 .env 中配置）
```

### 部署后验证

首次启动约需 **2～5 分钟**，按顺序检查：

```bash
cd fwwbb-newwin/docker

# 1. 容器状态（ragflow-cpu 应为 Up，非 Restarting）
docker compose ps

# 2. 端口监听（应看到 0.0.0.0:9222）
ss -tlnp | grep 9222

# 3. 本机 HTTP 探测（应返回 HTTP/1.1 200 OK）
curl -I http://127.0.0.1:9222

# 4. 查看 RAGFlow 日志（不应有 nginx emerg 报错）
docker compose logs ragflow-cpu --tail 30
```

**浏览器访问**（将 `10.x.x.x` 换成实际服务器 IP）：

| 用途 | 地址 |
|------|------|
| 首页 | http://10.x.x.x:9222 |
| 数据池 | http://10.x.x.x:9222/#/data-pool |
| 智能填表 | http://10.x.x.x:9222/#/form-fill |

> 笔记本访问服务器时，必须用 `http://<服务器IP>:9222`，**不能用** `localhost`（localhost 指向笔记本自身）。

---

## 日常运维命令

在 `fwwbb-newwin/docker` 目录下执行：

```bash
# 查看状态
docker compose ps

# 查看日志（实时）
docker compose logs -f ragflow-cpu

# 停止全部服务
docker compose down

# 启动全部服务
docker compose up -d

# 仅重启 RAGFlow 主服务
docker compose restart ragflow-cpu
```

---

## 更新部署包

当 GitHub 仓库有配置修复或版本更新时：

```bash
cd fwwbb-newwin
git pull

cd docker
docker compose pull                    # 若镜像版本有变
docker compose up -d --force-recreate ragflow-cpu

# 验证
curl -I http://127.0.0.1:9222
```

若只改了 compose / nginx 挂载而未改镜像，可省略 `docker compose pull`。

---

## 访问地址

| 服务 | 本机访问 | 局域网/远程访问 |
|------|----------|-----------------|
| 前端首页 | http://localhost:9222 | http://\<服务器IP\>:9222 |
| 数据池 | http://localhost:9222/#/data-pool | http://\<服务器IP\>:9222/#/data-pool |
| 智能填表 | http://localhost:9222/#/form-fill | http://\<服务器IP\>:9222/#/form-fill |
| 后端 API | http://localhost:9380 | http://\<服务器IP\>:9380 |

### 远程访问打不开？

按顺序排查：

1. **容器是否正常**：`docker compose ps`，`ragflow-cpu` 不能是 `Restarting`
2. **端口是否监听**：`ss -tlnp | grep 9222`（应看到 `0.0.0.0:9222`）
3. **本机是否通**：`curl -I http://127.0.0.1:9222`（应 200）
4. **防火墙**：`sudo ufw allow 9222/tcp && sudo ufw allow 9380/tcp`
5. **云服务器**：安全组放行 9222、9380
6. **配置更新后**：`docker compose up -d --force-recreate ragflow-cpu`

---

## 首次使用指南

### 1. 配置大模型（首次必做）

1. 打开 http://\<服务器IP\>:9222 ，注册并登录
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
| `ghcr.io/lsyy1/ragflow-fwwb:2.0.0` | 决赛版主服务（推荐，Public 可匿名拉取） |

```bash
docker pull ghcr.io/lsyy1/ragflow-fwwb:2.0.0
```

镜像页面：<https://github.com/lsyy1/fwwbb-newwin/pkgs/container/ragflow-fwwb>

**备用镜像**（若 GHCR 不可用，可在 `docker/.env` 中修改）：

```bash
RAGFLOW_IMAGE=lsyy1/ragflow-fwwb:2.0.0
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
├── deploy.sh                    # 一键部署脚本
├── docker/
│   ├── .env.example             # 环境配置模板（含 COMPOSE_PROFILES、镜像地址）
│   ├── docker-compose.yml       # RAGFlow 服务编排
│   ├── docker-compose-base.yml  # MySQL / ES / Redis / MinIO
│   ├── init.sql                 # MySQL 初始化
│   ├── entrypoint.sh            # 容器启动脚本
│   ├── service_conf.yaml.template
│   └── nginx/                   # nginx 配置（compose 挂载进容器）
│       ├── nginx.conf
│       ├── proxy.conf           # 挂载至 /etc/nginx/proxy.conf
│       └── ragflow.conf.python  # 挂载至 conf.d，启动时选用
└── README.md
```

---

## 常见问题

**Q：端口被占用怎么办？**  
修改 `docker/.env` 中的 `SVR_WEB_HTTP_PORT`（默认 9222）或 `SVR_HTTP_PORT`（默认 9380），然后 `docker compose up -d --force-recreate ragflow-cpu`。

**Q：`ragflow-cpu` 一直 Restarting？**  
查看日志：`docker compose logs ragflow-cpu --tail 50`。常见原因：
- nginx 配置缺失 → 确保已 `git pull` 最新部署包，并 `--force-recreate`
- MySQL 未就绪 → 等待 `mysql` 容器 Healthy 后自动恢复

**Q：日志出现 `proxy.conf failed (No such file or directory)`？**  
nginx 需要在 `/etc/nginx/proxy.conf` 找到代理配置。请更新到最新部署包（已修复挂载路径），然后：

```bash
cd docker && git pull && docker compose up -d --force-recreate ragflow-cpu
```

**Q：日志出现 `ragflow.conf.python: No such file`？**  
compose 需挂载 `docker/nginx/` 下各配置文件。同样 `git pull` 后重建容器即可。

**Q：本机 curl 200，笔记本访问不了？**  
检查防火墙 `sudo ufw allow 9222/tcp`；云主机检查安全组；确认笔记本与服务器在同一可达网络。

**Q：内存不足？**  
建议服务器 ≥ 16GB；可在 `.env` 中调整 `MEM_LIMIT`。

**Q：镜像拉取失败？**  
检查网络或配置 Docker 镜像加速；确认可访问 `ghcr.io`。

**Q：启动日志里 `Load term.freq FAIL` / `redis connection` 警告？**  
不影响 FWWB 数据池与智能填表核心功能，可忽略。

**Q：填表结果不准确？**  
检查数据池是否包含正确源文件、用户需求是否描述清晰、大模型 API Key 是否配置正常。

---

## 评委快速体验（3 步）

```bash
git clone https://github.com/lsyy1/fwwbb-newwin.git && cd fwwbb-newwin && ./deploy.sh
```

等待脚本输出「部署完成」后，浏览器打开 `http://<服务器IP>:9222/#/data-pool` → 注册登录 → 配置模型 API Key → 按「首次使用指南」操作即可。

---

## 许可证

基于 RAGFlow 二次开发，遵循上游开源协议。业务文档与答辩材料见主开发仓库。
