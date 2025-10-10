#!/bin/bash

# 阿里云服务器端部署验证脚本
# 用于验证FRP服务端和Nginx反向代理是否正常运行

echo "🔍 服务器端部署验证"
echo "=================="

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "❌ 错误：请使用root用户运行此脚本"
    echo "使用命令：sudo $0"
    exit 1
fi

echo "✅ 用户权限检查通过"

# 获取服务器IP
SERVER_IP=$(curl -s http://ipinfo.io/ip 2>/dev/null || curl -s http://ipecho.net/plain 2>/dev/null || hostname -I | awk '{print $1}' 2>/dev/null)

if [ -z "$SERVER_IP" ]; then
    echo "⚠️  警告：无法获取服务器公网IP"
    SERVER_IP="your-server-ip"
fi

echo "📍 服务器IP：$SERVER_IP"

# 检查Docker环境
echo ""
echo "🐳 Docker环境检查："
echo "-------------------"

if command -v docker &> /dev/null; then
    echo "✅ Docker已安装"

    if docker info > /dev/null 2>&1; then
        echo "✅ Docker服务运行正常"
    else
        echo "❌ Docker服务未运行"
        exit 1
    fi
else
    echo "❌ Docker未安装"
    exit 1
fi

# 检查Docker Compose
if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose已安装"
elif docker compose version > /dev/null 2>&1; then
    echo "✅ Docker Compose插件可用"
else
    echo "❌ Docker Compose未安装"
    exit 1
fi

# 检查容器状态
echo ""
echo "📦 容器状态检查："
echo "-----------------"

cd "$(dirname "${BASH_SOURCE[0]}")" || {
    echo "❌ 错误：无法进入脚本目录"
    exit 1
}

# 检查FRP服务端容器
if docker ps --filter "name=frps" --filter "status=running" | grep -q frps; then
    echo "✅ FRP服务端容器运行正常"

    # 检查FRP管理界面
    if curl -f -s "http://localhost:7500" > /dev/null; then
        echo "✅ FRP管理界面可访问：http://$SERVER_IP:7500"
    else
        echo "⚠️  FRP管理界面无法访问"
    fi
else
    echo "❌ FRP服务端容器未运行"
fi

# 检查Nginx容器
if docker ps --filter "name=nginx" --filter "status=running" | grep -q nginx; then
    echo "✅ Nginx容器运行正常"

    # 检查Nginx服务
    if curl -f -I "http://localhost" > /dev/null; then
        echo "✅ Nginx服务可访问：http://$SERVER_IP"
    else
        echo "⚠️  Nginx服务无法访问"
    fi
else
    echo "❌ Nginx容器未运行"
fi

# 检查端口开放情况
echo ""
echo "🔌 端口开放检查："
echo "-----------------"

PORTS=("80" "443" "7000" "7500")
for port in "${PORTS[@]}"; do
    if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
        echo "✅ 端口$port已开放"
    else
        echo "⚠️  端口$port未开放"
    fi
done

# 检查防火墙状态
echo ""
echo "🔥 防火墙检查："
echo "---------------"

if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
        echo "✅ UFW防火墙已启用"

        # 检查关键端口规则
        for port in 80 443 7000 7500; do
            if ufw status | grep -q "$port/tcp.*ALLOW"; then
                echo "✅ 端口$port已允许"
            else
                echo "⚠️  端口$port未在防火墙中允许"
            fi
        done
    else
        echo "⚠️  UFW防火墙未启用"
    fi
elif command -v firewall-cmd &> /dev/null; then
    if firewall-cmd --state 2>/dev/null | grep -q "running"; then
        echo "✅ firewalld运行正常"
    else
        echo "⚠️  firewalld未运行"
    fi
fi

# 检查网络连通性
echo ""
echo "🌐 网络连通性检查："
echo "--------------------"

# 测试外网连通性
if ping -c 1 -W 3 8.8.8.8 > /dev/null 2>&1; then
    echo "✅ 外网连通性正常"
else
    echo "⚠️  外网连通性异常"
fi

# 测试本地网络服务
if curl -f -s "http://localhost:7500" > /dev/null; then
    echo "✅ 本地FRP管理界面可访问"
else
    echo "❌ 本地FRP管理界面无法访问"
fi

if curl -f -I "http://localhost" > /dev/null; then
    echo "✅ 本地Nginx服务可访问"
else
    echo "❌ 本地Nginx服务无法访问"
fi

# 显示容器详情
echo ""
echo "📋 容器详情："
echo "-------------"
docker-compose ps

# 显示日志摘要
echo ""
echo "📜 最近日志："
echo "------------"
echo "FRP服务端日志："
docker-compose logs --tail=3 frps 2>/dev/null || echo "无FRP日志"

echo ""
echo "Nginx日志："
docker-compose logs --tail=3 nginx 2>/dev/null || echo "无Nginx日志"

# 生成验证报告
echo ""
echo "📊 部署验证报告"
echo "================"

ISSUES=0
WARNINGS=0

# 检查关键问题
if ! curl -f "http://localhost:7500" > /dev/null 2>&1; then
    echo "❌ 严重问题：FRP服务端无法访问"
    ((ISSUES++))
fi

if ! curl -f -I "http://localhost" > /dev/null 2>&1; then
    echo "❌ 严重问题：Nginx服务无法访问"
    ((ISSUES++))
fi

# 检查警告
if ! netstat -tuln 2>/dev/null | grep -q ":80 " && ! ss -tuln 2>/dev/null | grep -q ":80 "; then
    echo "⚠️  警告：HTTP端口(80)未开放"
    ((WARNINGS++))
fi

if ! netstat -tuln 2>/dev/null | grep -q ":7500 " && ! ss -tuln 2>/dev/null | grep -q ":7500 "; then
    echo "⚠️  警告：FRP管理端口(7500)未开放"
    ((WARNINGS++))
fi

echo ""
echo "📈 验证结果统计："
echo "- 严重问题：$ISSUES 个"
echo "- 警告项目：$WARNINGS 个"

if [ $ISSUES -eq 0 ]; then
    echo ""
    echo "🎉 部署验证通过！"
    echo "=================="
    echo "✅ 服务器端部署成功"
    echo ""
    echo "🔗 下一步："
    echo "1. 在本地启动博客服务"
    echo "2. 通过FRP连接测试外网访问"
    echo "3. 配置域名解析（可选）"
    echo ""
    echo "📚 相关命令："
    echo "启动本地服务：../start.sh"
    echo "查看FRP状态：docker-compose logs -f frps"
    echo "查看Nginx日志：docker-compose logs -f nginx"
else
    echo ""
    echo "❌ 部署验证失败！"
    echo "=================="
    echo "请解决上述问题后重新运行验证脚本"
    echo ""
    echo "🔧 故障排查："
    echo "1. 查看详细日志：docker-compose logs [服务名]"
    echo "2. 检查配置文件：vim nginx/blog.conf"
    echo "3. 检查防火墙设置：ufw status"
    echo "4. 重启服务：docker-compose restart"
fi

echo ""
echo "验证完成时间：$(date)"
echo "服务器IP：$SERVER_IP"
