# 个人博客系统

<div align="center">

![Logo](https://img.shields.io/badge/Blog-System-blue?style=flat-square)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7.14-brightgreen?style=flat-square&logo=spring-boot)
![Vue](https://img.shields.io/badge/Vue-3.3.4-brightgreen?style=flat-square&logo=vue.js)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=flat-square&logo=mysql)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)

基于Spring Boot + Vue.js的现代化全栈博客系统

[功能特性](#功能特性) • [快速开始](#快速开始) • [项目文档](#项目文档) • [技术栈](#技术栈) • [部署指南](#部署指南)

</div>

---

## 📖 项目简介

这是一个功能完善的个人博客系统，采用前后端分离架构，支持文章发布、AI智能对话等功能。为解决云服务器性能不足的问题，系统创新性地采用**FRP内网穿透**技术，将计算密集型服务部署在本地，通过反向代理实现外网访问，大幅降低部署成本。

### 🎯 项目亮点

- ✨ **混合部署架构**：阿里云服务器 + 本地服务器，低成本高性能
- 🤖 **AI集成**：集成vLLM高性能推理框架，提供智能对话功能
- 🚀 **现代化技术栈**：Vue 3 + Spring Boot + Docker
- 📱 **响应式设计**：完美适配PC、平板、移动端
- 🔒 **安全可靠**：JWT认证、权限控制、数据加密
- 📝 **Markdown支持**：完整的Markdown编辑和渲染
- 🎨 **优雅的UI**：基于Element Plus的现代化界面

## ✨ 功能特性

### 用户功能
- ✅ 用户注册与登录
- ✅ JWT Token认证
- ✅ 用户信息管理
- ✅ 权限控制

### 文章功能
- ✅ 文章发布与编辑
- ✅ Markdown编辑器
- ✅ 实时预览
- ✅ 文章分类与标签
- ✅ 文章搜索
- ✅ 浏览统计
- ✅ 代码高亮

### AI功能
- ✅ AI智能对话
- ✅ 本地大模型支持
- ✅ 对话历史记录
- ✅ Markdown格式回复

### 系统功能
- ✅ 内网穿透（FRP）
- ✅ 反向代理（Nginx）
- ✅ Docker容器化部署
- ✅ 日志记录
- ✅ 错误处理

## 🏗️ 项目结构

```
fin/
├── server/                 # 服务端（阿里云）
│   ├── nginx/             # Nginx配置
│   ├── frp/               # FRP服务端配置
│   ├── docker-compose.yml # Docker编排
│   └── README.md          # 服务端部署说明
├── local/                 # 本地端
│   ├── backend/           # Spring Boot后端
│   │   ├── src/
│   │   ├── pom.xml
│   │   └── Dockerfile
│   ├── frontend/          # Vue前端
│   │   ├── src/
│   │   ├── package.json
│   │   └── Dockerfile
│   ├── frp/               # FRP客户端配置
│   └── docker-compose.yml # Docker编排
├── docs/                  # 项目文档
│   ├── 需求文档.md
│   ├── 功能设计文档.md
│   ├── 部署文档.md
│   ├── 测试文档.md
│   └── PPT大纲.md
└── README.md              # 本文件
```

## 🛠️ 技术栈

### 后端技术

| 技术 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 2.7.14 | 核心框架 |
| Spring Security | 2.7.14 | 安全框架 |
| MyBatis Plus | 3.5.3 | ORM框架 |
| MySQL | 8.0 | 数据库 |
| JWT | 0.9.1 | 身份认证 |
| Lombok | - | 简化代码 |
| FastJSON | 2.0.43 | JSON处理 |

### 前端技术

| 技术 | 版本 | 说明 |
|------|------|------|
| Vue | 3.3.4 | 核心框架 |
| Vue Router | 4.2.5 | 路由管理 |
| Pinia | 2.1.7 | 状态管理 |
| Element Plus | 2.4.2 | UI组件库 |
| Axios | 1.6.0 | HTTP客户端 |
| Vite | 4.5.0 | 构建工具 |
| Marked | 9.1.2 | Markdown渲染 |
| Highlight.js | 11.9.0 | 代码高亮 |

### 部署技术

| 技术 | 说明 |
|------|------|
| Docker | 容器化部署 |
| Docker Compose | 容器编排 |
| Nginx | 反向代理 |
| FRP | 内网穿透 |
| vLLM | 高性能AI推理框架 |

## 🚀 快速开始

### 环境要求

**阿里云服务器**：
- CPU: 1核+
- 内存: 2GB+
- 操作系统: Ubuntu 20.04 / CentOS 7+
- Docker 20.10+

**本地服务器**：
- CPU: 4核+
- 内存: 8GB+
- 操作系统: Windows 10/11 或 Linux
- Docker 20.10+ / JDK 11+ / Node.js 16+
- MySQL 8.0+
- vLLM

### 快速部署

#### 1. 克隆项目

```bash
git clone https://github.com/yourusername/blog-system.git
cd blog-system
```

#### 2. 部署阿里云服务器

```bash
# 上传server目录到服务器
scp -r server root@your_server_ip:/root/blog-server

# SSH连接服务器
ssh root@your_server_ip

# 进入目录
cd /root/blog-server

# 修改配置
vim frp/frps.ini  # 修改token
vim nginx/blog.conf  # 修改域名

# 启动服务
docker-compose up -d

# 查看状态
docker-compose ps
```

#### 3. 部署本地服务器

**使用Docker部署（推荐）**：

```bash
# 进入本地目录
cd local

# 修改配置
# 编辑 frp/frpc.ini，修改server_addr和token
# 编辑 backend/src/main/resources/application.yml，修改数据库配置

# 构建后端
cd backend
mvn clean package -DskipTests
cd ..

# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f
```

**手动部署**：

请参考 [部署文档](docs/部署文档.md) 获取详细步骤。

#### 4. 安装vLLM（AI功能）

**Docker方式（推荐）**：
vLLM服务已在docker-compose.yml中配置，会自动启动。

**手动安装方式**：

```bash
# 安装vLLM
pip install vllm

# 启动vLLM服务（需要先下载模型）
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-2-7b-chat-hf \
  --host 0.0.0.0 \
  --port 8000
```

**使用本地模型**：
系统已配置为使用本地模型路径：`D:\code\llm\wyh\llm\Qwen3\Qwen3-4B-I-chat`

**如需使用其他模型**：
```bash
# 下载其他模型到指定路径
# 模型路径：D:\code\llm\wyh\llm\Qwen3\Qwen3-4B-I-chat
# 或者修改docker-compose.yml中的模型挂载路径
```

#### 5. 访问系统

- **前端页面**：http://your-domain.com 或 http://your-server-ip
- **后端API**：http://your-domain.com/api
- **FRP管理**：http://your-server-ip:7500

### 初始化数据库

```sql
-- 连接MySQL
mysql -u root -p

-- 创建数据库
CREATE DATABASE blog_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE blog_db;

-- 运行SQL脚本（在backend/src/main/resources/sql/目录下）
source schema.sql;
```

详细的SQL脚本请参考后端README。

## 📚 项目文档

完整的项目文档位于 `docs/` 目录：

- [需求文档](docs/需求文档.md) - 项目需求和功能规格
- [功能设计文档](docs/功能设计文档.md) - 系统架构和详细设计
- [部署文档](docs/部署文档.md) - 详细的部署步骤和配置
- [测试文档](docs/测试文档.md) - 测试用例和测试报告
- [PPT大纲](docs/PPT大纲.md) - 项目答辩PPT大纲

各模块详细文档：
- [后端README](local/backend/README.md) - 后端开发说明
- [前端README](local/frontend/README.md) - 前端开发说明
- [服务端README](server/README.md) - 服务器部署说明

## 🎨 界面预览

### 首页
![首页]
(添加截图)

### 文章列表
![文章列表]
(添加截图)

### 文章详情
![文章详情]
(添加截图)

### AI对话
![AI对话]
(添加截图)

## 🔧 开发指南

### 本地开发环境搭建

**后端开发**：
```bash
cd local/backend

# 使用Maven运行
mvn spring-boot:run

# 或使用IDE（IntelliJ IDEA推荐）
# 直接运行BlogApplication.java
```

**前端开发**：
```bash
cd local/frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问 http://localhost:3000
```

### 代码规范

- Java代码遵循阿里巴巴Java开发手册
- JavaScript代码使用ESLint规范
- 提交信息遵循Conventional Commits规范

### 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交Pull Request

## 🐛 问题反馈

如果遇到问题，请通过以下方式反馈：

- 提交 [Issue](https://github.com/yourusername/blog-system/issues)
- 发送邮件至：your@email.com

## 📈 未来规划

- [ ] 评论系统
- [ ] 点赞收藏功能
- [ ] 用户关注功能
- [ ] 文章专栏
- [ ] 全文搜索优化（Elasticsearch）
- [ ] Redis缓存
- [ ] CDN加速
- [ ] SEO优化
- [ ] 数据统计分析
- [ ] 移动端APP

## 📄 许可证

本项目采用 [MIT License](LICENSE) 许可证。

## 👨‍💻 作者

- **Your Name** - [GitHub](https://github.com/yourusername)

## 🙏 致谢

感谢以下开源项目：

- [Spring Boot](https://spring.io/projects/spring-boot)
- [Vue.js](https://vuejs.org/)
- [Element Plus](https://element-plus.org/)
- [MyBatis Plus](https://baomidou.com/)
- [FRP](https://github.com/fatedier/frp)
- [vLLM](https://github.com/vllm-project/vllm)

## 📞 联系方式

- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your@email.com
- 博客: https://yourblog.com

---

<div align="center">

**如果这个项目对你有帮助，请给个⭐️Star吧！**

Made with ❤️ by [Your Name]

</div>
