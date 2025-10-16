# 前端Dockerfile - 多阶段构建

# 第一阶段：构建
FROM node:22-alpine AS build

# 设置工作目录
WORKDIR /app

# 复制package文件
COPY package*.json ./

# 设置npm国内镜像源并安装依赖
RUN npm config set registry https://registry.npmmirror.com && \
    npm install

# 复制源代码
COPY . .

# 构建应用
RUN npm run build

# 第二阶段：生产环境
FROM nginx:stable-alpine

# 复制构建产物到nginx
COPY --from=build /app/dist /usr/share/nginx/html

# 复制nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]

