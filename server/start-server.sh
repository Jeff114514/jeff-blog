#!/bin/bash

# 阿里云服务器端启动脚本
# 用于启动FRP服务端和Nginx反向代理

echo "🚀 启动阿里云服务器端服务"
echo "=========================="

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "❌ 错误：请使用root用户运行此脚本"
    echo "使用命令：sudo $0"
    exit 1
fi

# 检查Docker是否安装和运行
if ! command -v docker &> /dev/null; then
    echo "❌ 错误：Docker未安装，请先安装Docker"
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo "❌ 错误：Docker服务未运行，请先启动Docker"
    echo "使用命令：systemctl start docker"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null && ! docker compose version > /dev/null 2>&1; then
    echo "❌ 错误：Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

echo "✅ Docker环境检查通过"

# 检查配置文件是否存在
SERVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SERVER_DIR/docker-compose.yml"
NGINX_CONFIG="$SERVER_DIR/nginx/blog.conf"
FRP_CONFIG="$SERVER_DIR/frp/frps.ini"

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ 错误：找不到docker-compose.yml文件：$COMPOSE_FILE"
    exit 1
fi

if [ ! -f "$NGINX_CONFIG" ]; then
    echo "❌ 错误：找不到Nginx配置文件：$NGINX_CONFIG"
    exit 1
fi

if [ ! -f "$FRP_CONFIG" ]; then
    echo "❌ 错误：找不到FRP配置文件：$FRP_CONFIG"
    exit 1
fi

echo "✅ 配置文件检查通过"

# 检查防火墙状态
if command -v ufw &> /dev/null; then
    echo "🔥 检查防火墙状态..."
    ufw status | grep -q "Status: active" || {
        echo "⚠️  警告：UFW防火墙未启用，建议启用防火墙"
        echo "启用命令：ufw enable"
    }
elif command -v firewall-cmd &> /dev/null; then
    echo "🔥 检查防火墙状态..."
    firewall-cmd --state 2>/dev/null | grep -q "running" || {
        echo "⚠️  警告：firewalld未运行，建议启动防火墙"
        echo "启动命令：systemctl start firewalld"
    }
fi

# 进入服务器目录
cd "$SERVER_DIR" || {
    echo "❌ 错误：无法进入服务器目录：$SERVER_DIR"
    exit 1
}

echo "🔧 启动FRP服务端..."
if ! docker-compose up -d frps 2>/dev/null && ! docker compose up -d frps 2>/dev/null; then
    echo "❌ FRP服务端启动失败"
    exit 1
fi

echo "🔧 启动Nginx反向代理..."
if ! docker-compose up -d nginx 2>/dev/null && ! docker compose up -d nginx 2>/dev/null; then
    echo "❌ Nginx启动失败"
    exit 1
fi

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 5

# 验证服务状态
echo ""
echo "📊 服务状态检查："
echo "=================="

# 检查FRP服务端
if curl -f http://localhost:7500 > /dev/null 2>&1; then
    echo "✅ FRP服务端运行正常"
    echo "   管理界面：http://$(curl -s http://ipinfo.io/ip):7500"
else
    echo "❌ FRP服务端启动失败"
    echo "查看日志：docker-compose logs frps"
fi

# 检查Nginx
if curl -f -I http://localhost > /dev/null 2>&1; then
    echo "✅ Nginx反向代理运行正常"
    echo "   HTTP服务：http://$(curl -s http://ipinfo.io/ip)"
else
    echo "❌ Nginx启动失败"
    echo "查看日志：docker-compose logs nginx"
fi

# 检查端口开放情况
echo ""
echo "🔌 端口开放检查："
echo "================="
PORTS=("80" "443" "7000" "7500")
for port in "${PORTS[@]}"; do
    if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
        echo "✅ 端口$port已开放"
    else
        echo "⚠️  端口$port未开放"
    fi
done

echo ""
echo "🎉 服务器端服务启动完成！"
echo "=========================="

echo ""
echo "📋 服务器信息："
SERVER_IP=$(curl -s http://ipinfo.io/ip)
echo "公网IP：$SERVER_IP"
echo "域名：请配置为指向 $SERVER_IP"

echo ""
echo "🔗 访问地址："
echo "博客首页：http://$SERVER_IP"
echo "FRP管理：http://$SERVER_IP:7500"

echo ""
echo "🛠️  常用管理命令："
echo "查看所有服务：docker-compose ps"
echo "查看服务日志：docker-compose logs -f [服务名]"
echo "重启服务：docker-compose restart [服务名]"
echo "停止服务：docker-compose down"
echo "更新服务：docker-compose up -d --force-recreate"

echo ""
echo "📚 相关文档："
echo "部署指南：../docs/部署文档.md"
echo "服务器说明：README.md"

echo ""
echo "⚠️  重要提醒："
echo "1. 请确保域名解析已配置到：$SERVER_IP"
echo "2. 请检查防火墙是否放行必要端口"
echo "3. 请备份重要数据"
echo "4. 如需SSL证书，请参考部署文档"

echo ""
echo "🎯 下一步："
echo "1. 在本地启动博客服务（运行../start.sh）"
echo "2. 测试外网访问功能"
echo "3. 配置域名解析（可选）"

echo ""
echo "有问题请查看日志或联系管理员。"
