# vLLM AI服务部署指南

## 概述

vLLM是一个高性能的大语言模型推理框架，用于替代原有的Ollama服务。vLLM提供了与OpenAI API兼容的接口，具有更高的性能和更好的内存管理。

## 主要优势

- 🚀 **高性能**：比传统推理框架快数倍
- 💾 **内存优化**：支持更大的模型和更高的吞吐量
- 🔧 **易集成**：提供OpenAI兼容的API接口
- ⚡ **批处理**：支持动态批处理和连续批处理
- 🛠️ **易扩展**：支持模型并行和张量并行

## 系统要求

### 硬件要求
- **GPU**：推荐NVIDIA GPU（RTX 30系列或更高）
- **内存**：至少8GB RAM
- **硬盘**：至少50GB可用空间（用于模型存储）

### 软件要求
- Python 3.8+
- CUDA 11.8+
- PyTorch 2.0+
- 网络连接（用于下载模型）

## 安装方式

### 方式一：Docker部署（推荐）

vLLM服务已在项目的`docker-compose.yml`中配置，会自动启动。

```bash
cd local
docker-compose up -d vllm
```

### 方式二：手动安装

```bash
# 安装vLLM
pip install vllm

# 或者从源码安装
git clone https://github.com/vllm-project/vllm.git
cd vllm
pip install -e .
```

## 模型准备

### 本地模型配置

当前项目已配置为使用本地Qwen模型：
- **模型路径**：`D:\code\llm\wyh\llm\Qwen3\Qwen3-4B-I-chat`
- **容器内路径**：`/models/Qwen3-4B-I-chat`
- **模型类型**：Qwen3-4B-I-chat

### 下载模型

**使用Docker（推荐）**：

模型会自动下载到容器内的`/models`目录。

**手动下载**：

**本地模型使用**：
项目已配置为使用指定的本地模型路径。确保模型文件完整：

**必需的文件**：
- `config.json` - 模型配置文件
- `tokenizer.json` 或 `tokenizer.model` - 分词器文件
- `pytorch_model.bin` 或 `model.safetensors` - 模型权重文件
- 其他必要的模型组件文件

**模型路径**：`D:\code\llm\wyh\llm\Qwen3\Qwen3-4B-I-chat`

**验证模型**：
```bash
# 检查模型文件是否存在
ls -la "D:\code\llm\wyh\llm\Qwen3\Qwen3-4B-I-chat"

# 验证模型完整性
python -c "
import json
import os

model_path = r'D:\code\llm\wyh\llm\Qwen3\Qwen3-4B-I-chat'
config_file = os.path.join(model_path, 'config.json')

if os.path.exists(config_file):
    with open(config_file, 'r') as f:
        config = json.load(f)
    print(f'模型配置加载成功: {config.get(\"model_type\", \"未知\")}')
    print(f'词汇表大小: {config.get(\"vocab_size\", \"未知\")}')
else:
    print('模型配置文件不存在')
"
```

## 启动服务

### Docker方式

服务已在`docker-compose.yml`中配置为使用本地模型：

```yaml
vllm:
  image: vllm/vllm-openai:latest
  container_name: vllm
  ports:
    - "8000:8000"
  environment:
    - MODEL_NAME=Qwen3-4B-I-chat
  volumes:
    - D:\code\llm\wyh\llm\Qwen3\Qwen3-4B-I-chat:/models/Qwen3-4B-I-chat:ro
    - ./config:/config:ro
  command: >
    --model /models/Qwen3-4B-I-chat
    --host 0.0.0.0
    --port 8000
    --config /config/vllm_config.json
```

启动命令：
```bash
docker-compose up -d vllm
```

### 手动方式

```bash
# 启动vLLM服务
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-2-7b-chat-hf \
  --host 0.0.0.0 \
  --port 8000 \
  --max-model-len 2048 \
  --gpu-memory-utilization 0.9 \
  --tensor-parallel-size 1
```

## API接口

vLLM提供与OpenAI兼容的API接口。

### 健康检查

```bash
curl http://localhost:8000/health
```

### 获取模型列表

```bash
curl http://localhost:8000/v1/models
```

### 聊天接口

```bash
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "meta-llama/Llama-2-7b-chat-hf",
    "messages": [
      {"role": "system", "content": "你是一个有用的助手"},
      {"role": "user", "content": "你好"}
    ],
    "max_tokens": 100,
    "temperature": 0.7
  }'
```

## 配置说明

### 后端配置

在`application.yml`中配置：

```yaml
ai:
  vllm:
    url: http://localhost:8000/v1/chat/completions
    model: meta-llama/Llama-2-7b-chat-hf
    api-key: your-api-key-here  # 可选
    timeout: 180000
    max-tokens: 1024
    temperature: 0.7
    top-p: 0.9
```

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| MODEL_NAME | meta-llama/Llama-2-7b-chat-hf | 模型名称 |
| MAX_MODEL_LEN | 2048 | 最大序列长度 |
| GPU_MEMORY_UTILIZATION | 0.9 | GPU内存使用率 |
| TENSOR_PARALLEL_SIZE | 1 | 张量并行大小 |

## 性能调优

### GPU优化

```bash
# 检查GPU状态
nvidia-smi

# 监控GPU使用率
watch -n 1 nvidia-smi
```

### 内存优化

- 调整`--gpu-memory-utilization`参数
- 使用`--max-model-len`限制序列长度
- 启用`--tensor-parallel-size`进行张量并行

### 批处理优化

vLLM自动处理批处理，通常不需要手动配置。可以通过以下参数调整：

```bash
--max-num-seqs 256        # 最大序列数
--max-num-batched-tokens  # 最大批处理token数
```

## 故障排查

### 常见问题

#### 1. GPU内存不足

**现象**：CUDA out of memory错误

**解决方案**：
- 降低`--gpu-memory-utilization`值
- 减少`--max-model-len`长度
- 使用更小的模型

#### 2. 模型下载失败

**现象**：模型下载超时或失败

**解决方案**：
- 检查网络连接
- 使用国内镜像源
- 手动下载模型文件

#### 3. 服务启动失败

**现象**：端口被占用或CUDA错误

**解决方案**：
```bash
# 检查端口
netstat -tulpn | grep 8000

# 释放端口
kill -9 <PID>

# 检查CUDA版本
nvidia-smi
nvcc --version
```

### 日志查看

```bash
# Docker日志
docker-compose logs -f vllm

# 手动安装日志
tail -f /var/log/vllm.log
```

## 监控和维护

### 性能监控

```bash
# 实时性能监控
docker stats vllm

# GPU监控
nvidia-smi -l 1

# 服务健康检查
curl -f http://localhost:8000/health || echo "服务异常"
```

### 定期维护

1. **模型更新**：定期更新到最新版本的模型
2. **依赖更新**：保持vLLM和相关依赖为最新版本
3. **日志清理**：定期清理旧日志文件
4. **性能优化**：根据使用情况调整参数

## 扩展配置

### 多模型支持

vLLM支持同时加载多个模型：

```bash
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-2-7b-chat-hf \
  --model microsoft/DialoGPT-medium \
  --host 0.0.0.0 \
  --port 8000
```

### 高可用部署

```yaml
# docker-compose高可用配置
vllm:
  image: vllm/vllm-openai:latest
  deploy:
    replicas: 2
  # ... 其他配置
```

## 参考资料

- [vLLM官方文档](https://vllm.readthedocs.io/)
- [vLLM GitHub](https://github.com/vllm-project/vllm)
- [Hugging Face模型](https://huggingface.co/models)
- [OpenAI API文档](https://platform.openai.com/docs/api-reference)

## 更新日志

### v1.0.0 (2025-10-10)
- 初始版本，支持Llama-2模型
- Docker容器化部署
- OpenAI兼容API接口
- 高性能推理优化

---

**注意**：使用vLLM需要确保模型文件的合法性和版权合规。请遵守相关开源协议和使用条款。

