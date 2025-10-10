# 阿里云服务器端部署指南

本目录包含阿里云服务器端的配置文件和启动脚本。

## 🎯 快速开始

### 使用启动脚本（推荐）

**Linux/macOS**：
```bash
# 给脚本添加执行权限
chmod +x start-server.sh

# 启动所有服务
sudo ./start-server.sh
```

**Windows**：
```bat
REM 以管理员身份运行
start-server.bat
```

### 手动启动

```bash
# 启动FRP服务端
docker-compose up -d frps

# 启动Nginx反向代理
docker-compose up -d nginx

# 查看服务状态
docker-compose ps
```

## 目录结构

```
server/
├── nginx/                    # Nginx反向代理配置
│   └── blog.conf             # 反向代理配置文件
├── frp/                     # FRP内网穿透服务端配置
│   ├── frps.ini             # FRP服务端配置文件
│   └── frps.service         # FRP系统服务配置
├── start-server.sh          # 服务器启动脚本（Linux）
├── start-server.bat         # 服务器启动脚本（Windows）
├── verify-deployment.sh     # 部署验证脚本
├── docker-compose.yml       # Docker容器编排
└── README.md               # 本文件
```

## 📋 前置要求

### 硬件要求
- CPU：1核以上
- 内存：2GB以上
- 硬盘：20GB以上
- 公网IP：必须有公网IP或已配置域名

### 软件环境
- Docker 20.10+
- Docker Compose 1.29+
- Ubuntu 20.04+ / CentOS 7+ / Windows Server

### 网络要求
需开放以下端口：
- 80 (HTTP)
- 443 (HTTPS，可选)
- 7000 (FRP服务端口)
- 7500 (FRP管理界面)

## 🚀 部署步骤

### 1. 安装Docker环境

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Docker
curl -fsSL https://get.docker.com | sh

# 启动Docker服务
sudo systemctl start docker
sudo systemctl enable docker

# 安装Docker Compose
sudo apt install docker-compose -y

# 验证安装
docker --version
docker-compose --version
```

### 2. 配置防火墙

```bash
# Ubuntu/Debian (UFW)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 7000/tcp
sudo ufw allow 7500/tcp
sudo ufw enable

# CentOS (firewalld)
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=7000/tcp
sudo firewall-cmd --permanent --add-port=7500/tcp
sudo firewall-cmd --reload
```

### 3. 修改配置文件

编辑 `frp/frps.ini`：
```ini
# 修改认证令牌（重要！）
token = your_secure_token_here

# 修改管理界面密码
dashboard_user = admin
dashboard_pwd = your_admin_password

# 修改域名（可选）
subdomain_host = your-domain.com
```

编辑 `nginx/blog.conf`：
```nginx
# 修改域名
server_name your-domain.com;
```

### 4. 启动服务

**使用启动脚本（推荐）**：
```bash
# Linux/macOS
sudo ./start-server.sh

# Windows（管理员权限）
start-server.bat
```

**手动启动**：
```bash
# 启动FRP服务端
docker-compose up -d frps

# 启动Nginx
docker-compose up -d nginx

# 查看状态
docker-compose ps
```

### 5. 验证部署

运行部署验证脚本：
```bash
# Linux/macOS
sudo ./verify-deployment.sh

# 或手动检查
curl http://localhost:7500  # FRP管理界面
curl -I http://localhost     # Nginx服务
```

## 📊 服务管理

### 查看服务状态
```bash
docker-compose ps
```

### 查看服务日志
```bash
# 查看所有日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f frps
docker-compose logs -f nginx
```

### 重启服务
```bash
# 重启所有服务
docker-compose restart

# 重启特定服务
docker-compose restart frps
docker-compose restart nginx
```

### 停止服务
```bash
# 停止所有服务
docker-compose down

# 停止并删除容器（保留数据）
docker-compose down

# 停止并删除容器和数据卷
docker-compose down -v
```

### 更新服务
```bash
# 重新构建并启动
docker-compose up -d --force-recreate

# 更新镜像后重启
docker-compose pull
docker-compose up -d
```

## 🔧 高级配置

### FRP配置详解

`frp/frps.ini` 主要配置项：
```ini
[common]
# FRP服务端监听端口
bind_port = 7000

# 管理界面端口
dashboard_port = 7500

# 认证令牌（客户端必须一致）
token = your_secure_token

# 管理界面认证
dashboard_user = admin
dashboard_pwd = your_password

# 域名（用于子域名代理）
subdomain_host = your-domain.com
```

### Nginx配置详解

`nginx/blog.conf` 代理规则：
```nginx
# HTTP代理到本地服务
location / {
    proxy_pass http://127.0.0.1:3000;  # 前端服务
}

# API代理
location /api/ {
    proxy_pass http://127.0.0.1:8080/;  # 后端API
}

# AI服务代理
location /ai/ {
    proxy_pass http://127.0.0.1:8000/;  # vLLM服务
}
```

## 🚨 故障排查

### 常见问题

#### 1. Docker容器无法启动
```bash
# 检查Docker服务状态
sudo systemctl status docker

# 查看容器日志
docker-compose logs [container_name]

# 检查系统资源
df -h  # 磁盘空间
free -h  # 内存使用
```

#### 2. FRP连接失败
```bash
# 检查端口监听
netstat -tuln | grep 7000

# 测试FRP服务
curl http://localhost:7500

# 检查客户端配置中的token是否一致
```

#### 3. Nginx代理失败
```bash
# 检查Nginx配置语法
docker-compose exec nginx nginx -t

# 查看Nginx错误日志
docker-compose logs nginx

# 测试代理服务
curl -H "Host: your-domain.com" http://localhost
```

#### 4. 端口被占用
```bash
# 查看端口占用
netstat -tuln | grep [port]

# 杀死占用进程
sudo kill -9 [PID]

# 或修改配置文件中的端口
```

### 诊断脚本

运行部署验证脚本获取详细诊断信息：
```bash
sudo ./verify-deployment.sh
```

## 🔒 安全建议

1. **修改默认密码**：更改FRP管理界面密码
2. **使用强认证令牌**：设置复杂的token值
3. **启用防火墙**：只开放必要端口
4. **定期更新**：保持Docker镜像和系统更新
5. **监控日志**：定期检查服务日志
6. **备份配置**：定期备份配置文件

## 📈 监控和维护

### 日志管理
```bash
# 查看实时日志
docker-compose logs -f

# 导出日志
docker-compose logs > server.log

# 日志轮转（配置logrotate）
sudo vim /etc/logrotate.d/blog-server
```

### 性能监控
```bash
# 系统资源监控
htop

# Docker资源使用
docker stats

# 网络连接监控
netstat -tuln | grep LISTEN
```

### 定期维护
- 监控磁盘空间使用
- 检查服务运行状态
- 更新Docker镜像
- 备份配置文件
- 审查安全日志

## 📚 参考资料

- [Docker官方文档](https://docs.docker.com/)
- [FRP官方文档](https://gofrp.org/)
- [Nginx文档](https://nginx.org/en/docs/)
- [阿里云服务器指南](https://help.aliyun.com/)

## 🤝 技术支持

如果遇到问题，请：

1. 运行验证脚本：`sudo ./verify-deployment.sh`
2. 查看详细日志：`docker-compose logs [服务名]`
3. 检查配置文件语法
4. 确认网络和防火墙设置

如需进一步帮助，请联系开发团队或提交Issue。

