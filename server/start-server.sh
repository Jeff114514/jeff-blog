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
FRP_CONFIG="$SERVER_DIR/frp/frps.yml"

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

# 获取服务器IP（带错误处理）
SERVER_IP=$(curl -s http://ipinfo.io/ip 2>/dev/null || curl -s http://ipecho.net/plain 2>/dev/null || hostname -I | awk '{print $1}' 2>/dev/null)
if [ -z "$SERVER_IP" ]; then
    echo "⚠️  警告：无法获取服务器公网IP，将使用默认值"
    SERVER_IP="your-server-ip"
fi

# 加载环境变量
if [ -f ".env" ]; then
    echo "📄 加载环境变量配置..."
    source .env
    echo "✅ 环境变量加载完成"
fi

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

# 读取FRP管理界面认证信息（如果存在）
FRPS_CONFIG="./frp/frps.yml"
FRP_USER=""
FRP_PASS=""
if [ -f "$FRPS_CONFIG" ]; then
    FRP_USER=$(awk 'f&&/user:/ {gsub(/"|\x27/, ""); print $2; exit} /^webServer:/ {f=1}' "$FRPS_CONFIG" 2>/dev/null)
    FRP_PASS=$(awk 'f&&/password:/ {gsub(/"|\x27/, ""); print $2; exit} /^webServer:/ {f=1}' "$FRPS_CONFIG" 2>/dev/null)
fi

# 统一的FRP管理界面可达性检查：
# - 如配置了BasicAuth则携带认证
# - HTTP 2xx / 3xx 或 401（需要认证）都视为"可访问"（服务正常对外响应/重定向）
check_frp_admin_access() {
    local CURL_AUTH_ARGS=()
    if [ -n "$FRP_USER" ] && [ -n "$FRP_PASS" ]; then
        CURL_AUTH_ARGS=(-u "$FRP_USER:$FRP_PASS")
    fi
    local CODE
    CODE=$(curl -s -o /dev/null -w "%{http_code}" "${CURL_AUTH_ARGS[@]}" "http://localhost:7500" || echo "000")
    echo "$CODE"
}

# 验证服务状态
echo ""
echo "📊 服务状态检查："
echo "=================="

# 检查FRP服务端
HTTP_CODE=$(check_frp_admin_access)
if [[ "$HTTP_CODE" =~ ^2 ]] || [[ "$HTTP_CODE" =~ ^3 ]] || [ "$HTTP_CODE" = "401" ]; then
    echo "✅ FRP服务端运行正常 (HTTP $HTTP_CODE)"
    echo "   管理界面：http://$SERVER_IP:7500"
else
    echo "❌ FRP服务端启动失败 (HTTP $HTTP_CODE)"
    echo "查看日志：docker-compose logs frps"
fi

# 检查Nginx
if curl -f -I http://localhost > /dev/null 2>&1; then
    echo "✅ Nginx反向代理运行正常"
    echo "   HTTP服务：http://$SERVER_IP"
else
    echo "❌ Nginx启动失败"
    echo "查看日志：docker-compose logs nginx"
fi

# 检查端口开放情况
echo ""
echo "🔌 端口开放检查："
echo "================="
# 从环境变量读取端口配置，如果没有设置则使用默认值
HTTP_PORT="${NGINX_HTTP_PORT:-80}"
HTTPS_PORT="${NGINX_HTTPS_PORT:-443}"
FRP_PORT="${FRP_BIND_PORT:-7000}"
DASHBOARD_PORT="${FRP_DASHBOARD_PORT:-7500}"

PORTS=("$HTTP_PORT" "$HTTPS_PORT" "$FRP_PORT" "$DASHBOARD_PORT")
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
