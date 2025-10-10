#!/bin/bash

# 个人博客系统启动脚本
# 使用本地Qwen模型的vLLM部署

echo "🚀 启动个人博客系统（使用本地Qwen模型）"
echo "========================================"

# 检查模型文件是否存在
MODEL_PATH="D:/code/llm/wyh/llm/Qwen3/Qwen3-4B-I-chat"
if [ ! -d "$MODEL_PATH" ]; then
    echo "❌ 错误：模型目录不存在：$MODEL_PATH"
    echo "请确保Qwen模型已下载到指定路径"
    exit 1
fi

# 检查必需的模型文件
REQUIRED_FILES=("config.json" "tokenizer.json" "pytorch_model.bin")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$MODEL_PATH/$file" ]; then
        echo "❌ 错误：模型文件缺失：$file"
        echo "请确保模型文件完整"
        exit 1
    fi
done

echo "✅ 模型文件检查通过"

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ 错误：Docker未运行，请先启动Docker"
    exit 1
fi

# 进入项目目录
cd "$(dirname "$0")/local" || {
    echo "❌ 错误：无法进入项目目录"
    exit 1
}

echo "🔧 启动vLLM服务..."
docker-compose up -d vllm

# 等待vLLM启动
echo "⏳ 等待vLLM服务启动..."
sleep 10

# 检查vLLM服务状态
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ vLLM服务启动成功"
else
    echo "❌ vLLM服务启动失败，请检查日志："
    docker-compose logs vllm
    exit 1
fi

echo "🔧 启动后端服务..."
docker-compose up -d backend

echo "🔧 启动前端服务..."
docker-compose up -d frontend

echo "🔧 启动FRP客户端..."
docker-compose up -d frpc

echo ""
echo "🎉 所有服务启动完成！"
echo "========================================"
echo "📝 服务状态："
docker-compose ps

echo ""
echo "🔗 访问地址："
echo "前端页面：http://localhost:3000"
echo "后端API：http://localhost:8080"
echo "vLLM API：http://localhost:8000"
echo "FRP管理：http://localhost:7500"

echo ""
echo "🛠️  常用命令："
echo "查看日志：docker-compose logs -f [服务名]"
echo "停止服务：docker-compose down"
echo "重启服务：docker-compose restart"

echo ""
echo "📚 如需帮助，请查看："
echo "- 项目总览：项目总览.md"
echo "- 部署文档：docs/部署文档.md"
echo "- 本地模型指南：local/本地模型使用指南.md"
