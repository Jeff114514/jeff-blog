@echo off
REM 阿里云服务器端启动脚本（Windows版本）
REM 用于启动FRP服务端和Nginx反向代理

setlocal enabledelayedexpansion

echo 🚀 启动阿里云服务器端服务
echo ==========================

REM 检查是否为管理员权限
net session >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ 管理员权限确认
) else (
    echo ❌ 错误：请以管理员身份运行此脚本
    echo 右键脚本 - "以管理员身份运行"
    pause
    exit /b 1
)

REM 检查Docker是否安装和运行
docker version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：Docker未安装，请先安装Docker Desktop
    pause
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：Docker服务未运行，请先启动Docker Desktop
    pause
    exit /b 1
)

echo ✅ Docker环境检查通过

REM 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
set "SERVER_DIR=%SCRIPT_DIR%"
if "%SERVER_DIR:~-1%"=="\" set "SERVER_DIR=%SERVER_DIR:~0,-1%"

REM 检查配置文件是否存在
set "COMPOSE_FILE=%SERVER_DIR%\docker-compose.yml"
set "NGINX_CONFIG=%SERVER_DIR%\nginx\blog.conf"
set "FRP_CONFIG=%SERVER_DIR%\frp\frps.yml"

if not exist "%COMPOSE_FILE%" (
    echo ❌ 错误：找不到docker-compose.yml文件：%COMPOSE_FILE%
    pause
    exit /b 1
)

if not exist "%NGINX_CONFIG%" (
    echo ❌ 错误：找不到Nginx配置文件：%NGINX_CONFIG%
    pause
    exit /b 1
)

if not exist "%FRP_CONFIG%" (
    echo ❌ 错误：找不到FRP配置文件：%FRP_CONFIG%
    pause
    exit /b 1
)

echo ✅ 配置文件检查通过

REM 加载环境变量
if exist ".env" (
    echo 📄 加载环境变量配置...
    for /f "tokens=*" %%i in (.env) do (
        set "%%i"
    )
    echo ✅ 环境变量加载完成
) else (
    echo 📄 未找到.env文件，将使用默认配置
)

REM 检查防火墙状态
echo 🔥 检查防火墙状态...
netsh advfirewall show allprofiles state | findstr /C:"启用" >nul
if errorlevel 1 (
    echo ⚠️  警告：Windows防火墙可能未启用
    echo 建议检查防火墙设置，放行必要端口
) else (
    echo ✅ 防火墙已启用
)

REM 进入服务器目录
cd /d "%SERVER_DIR%"
if errorlevel 1 (
    echo ❌ 错误：无法进入服务器目录：%SERVER_DIR%
    pause
    exit /b 1
)

echo 🔧 启动FRP服务端...
docker-compose up -d frps
if errorlevel 1 (
    echo ❌ FRP服务端启动失败
    pause
    exit /b 1
)

echo 🔧 启动Nginx反向代理...
docker-compose up -d nginx
if errorlevel 1 (
    echo ❌ Nginx启动失败
    pause
    exit /b 1
)

REM 等待服务启动
echo ⏳ 等待服务启动...
timeout /t 8 /nobreak >nul

echo.
echo 📊 服务状态检查：
echo ==================

REM 获取服务器IP
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /C:"IPv4"') do (
    set "SERVER_IP=%%i"
    goto :check_ip
)
:check_ip
set "SERVER_IP=%SERVER_IP: =%"
if "%SERVER_IP%"=="" set "SERVER_IP=localhost"

REM 检查FRP服务端
curl -f http://localhost:7500 >nul 2>&1
if errorlevel 1 (
    echo ❌ FRP服务端启动失败
    echo 查看日志：docker-compose logs frps
) else (
    echo ✅ FRP服务端运行正常
    echo    管理界面：http://%SERVER_IP%:7500
)

REM 检查Nginx
curl -f -I http://localhost >nul 2>&1
if errorlevel 1 (
    echo ❌ Nginx启动失败
    echo 查看日志：docker-compose logs nginx
) else (
    echo ✅ Nginx反向代理运行正常
    echo    HTTP服务：http://%SERVER_IP%
)

echo.
echo 🔌 端口开放检查：
echo =================
REM 从环境变量读取端口配置，如果没有设置则使用默认值
if "%NGINX_HTTP_PORT%"=="" set "NGINX_HTTP_PORT=80"
if "%NGINX_HTTPS_PORT%"=="" set "NGINX_HTTPS_PORT=443"
if "%FRP_BIND_PORT%"=="" set "FRP_BIND_PORT=7000"
if "%FRP_DASHBOARD_PORT%"=="" set "FRP_DASHBOARD_PORT=7500"

set "PORTS=%NGINX_HTTP_PORT% %NGINX_HTTPS_PORT% %FRP_BIND_PORT% %FRP_DASHBOARD_PORT%"
for %%p in (%PORTS%) do (
    netstat -an | findstr ":%%p " >nul
    if errorlevel 1 (
        echo ⚠️  端口%%p未开放
    ) else (
        echo ✅ 端口%%p已开放
    )
)

echo.
echo 🎉 服务器端服务启动完成！
echo ==========================

echo.
echo 📋 服务器信息：
echo 公网IP：%SERVER_IP%
echo 域名：请配置为指向 %SERVER_IP%

echo.
echo 🔗 访问地址：
echo 博客首页：http://%SERVER_IP%
echo FRP管理：http://%SERVER_IP%:7500

echo.
echo 🛠️  常用管理命令：
echo 查看所有服务：docker-compose ps
echo 查看服务日志：docker-compose logs -f [服务名]
echo 重启服务：docker-compose restart [服务名]
echo 停止服务：docker-compose down
echo 更新服务：docker-compose up -d --force-recreate

echo.
echo 📚 相关文档：
echo 部署指南：../docs/部署文档.md
echo 服务器说明：README.md

echo.
echo ⚠️  重要提醒：
echo 1. 请确保域名解析已配置到：%SERVER_IP%
echo 2. 请检查防火墙是否放行必要端口
echo 3. 请备份重要数据
echo 4. 如需SSL证书，请参考部署文档

echo.
echo 🎯 下一步：
echo 1. 在本地启动博客服务（运行../start.bat）
echo 2. 测试外网访问功能
echo 3. 配置域名解析（可选）

echo.
echo 有问题请查看日志或联系管理员。

pause
