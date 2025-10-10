@echo off
REM 个人博客系统启动脚本（Windows版本）
REM 使用本地Qwen模型的vLLM部署

echo 🚀 启动个人博客系统（使用本地Qwen模型）
echo ========================================

REM 检查模型文件是否存在
set "MODEL_PATH=D:\code\llm\wyh\llm\Qwen3\Qwen3-4B-I-chat"
if not exist "%MODEL_PATH%" (
    echo ❌ 错误：模型目录不存在：%MODEL_PATH%
    echo 请确保Qwen模型已下载到指定路径
    pause
    exit /b 1
)

REM 检查必需的模型文件
set "REQUIRED_FILES=config.json tokenizer.json pytorch_model.bin"
for %%f in (%REQUIRED_FILES%) do (
    if not exist "%MODEL_PATH%\%%f" (
        echo ❌ 错误：模型文件缺失：%%f
        echo 请确保模型文件完整
        pause
        exit /b 1
    )
)

echo ✅ 模型文件检查通过

REM 检查Docker是否运行
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：Docker未运行，请先启动Docker Desktop
    pause
    exit /b 1
)

REM 进入项目目录
cd /d "%~dp0local"
if errorlevel 1 (
    echo ❌ 错误：无法进入项目目录
    pause
    exit /b 1
)

echo 🔧 启动vLLM服务...
docker-compose up -d vllm

REM 等待vLLM启动
echo ⏳ 等待vLLM服务启动...
timeout /t 10 /nobreak >nul

REM 检查vLLM服务状态
curl -f http://localhost:8000/health >nul 2>&1
if errorlevel 1 (
    echo ❌ vLLM服务启动失败，请检查日志：
    docker-compose logs vllm
    pause
    exit /b 1
) else (
    echo ✅ vLLM服务启动成功
)

echo 🔧 启动后端服务...
docker-compose up -d backend

echo 🔧 启动前端服务...
docker-compose up -d frontend

echo 🔧 启动FRP客户端...
docker-compose up -d frpc

echo.
echo 🎉 所有服务启动完成！
echo ========================================
echo 📝 服务状态：
docker-compose ps

echo.
echo 🔗 访问地址：
echo 前端页面：http://localhost:3000
echo 后端API：http://localhost:8080
echo vLLM API：http://localhost:8000
echo FRP管理：http://localhost:7500

echo.
echo 🛠️  常用命令：
echo 查看日志：docker-compose logs -f [服务名]
echo 停止服务：docker-compose down
echo 重启服务：docker-compose restart

echo.
echo 📚 如需帮助，请查看：
echo - 项目总览：项目总览.md
echo - 部署文档：docs/部署文档.md
echo - 本地模型指南：local/本地模型使用指南.md

pause
