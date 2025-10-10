# 博客前端系统

基于Vue 3和Element Plus的现代化博客前端应用。

## 技术栈

- Vue 3 (Composition API)
- Vue Router 4
- Pinia (状态管理)
- Element Plus (UI组件库)
- Vite (构建工具)
- Axios (HTTP客户端)
- Marked (Markdown渲染)
- Highlight.js (代码高亮)

## 项目结构

```
frontend/
├── public/              # 静态资源
├── src/
│   ├── api/            # API接口
│   ├── assets/         # 资源文件
│   ├── components/     # 公共组件
│   │   ├── Header.vue
│   │   └── Footer.vue
│   ├── router/         # 路由配置
│   ├── store/          # 状态管理
│   ├── views/          # 页面组件
│   │   ├── Home.vue
│   │   ├── Login.vue
│   │   ├── Register.vue
│   │   ├── ArticleList.vue
│   │   ├── ArticleDetail.vue
│   │   ├── CreateArticle.vue
│   │   └── AIChat.vue
│   ├── App.vue         # 根组件
│   └── main.js         # 入口文件
├── package.json        # 依赖配置
├── vite.config.js      # Vite配置
└── Dockerfile          # Docker构建文件
```

## 功能特性

### 用户功能
- ✅ 用户注册/登录
- ✅ 用户信息管理

### 文章功能
- ✅ 文章列表（分页、搜索）
- ✅ 文章详情（Markdown渲染）
- ✅ 文章创建（Markdown编辑器）
- ✅ 文章分类和标签
- ✅ 文章预览

### AI功能
- ✅ AI智能对话
- ✅ 消息历史记录
- ✅ Markdown格式支持

### UI/UX
- ✅ 响应式设计
- ✅ 现代化界面
- ✅ 流畅动画
- ✅ 暗色模式支持

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 开发环境运行

```bash
npm run dev
```

应用将在 http://localhost:3000 启动

### 3. 生产环境构建

```bash
npm run build
```

构建产物将生成在 `dist` 目录

### 4. 预览生产构建

```bash
npm run preview
```

## 环境变量

创建 `.env.local` 文件配置环境变量：

```env
# API基础URL
VITE_API_URL=http://localhost:8080/api
```

## Docker部署

### 构建镜像

```bash
docker build -t blog-frontend:1.0.0 .
```

### 运行容器

```bash
docker run -d -p 3000:80 --name blog-frontend blog-frontend:1.0.0
```

## 项目配置

### Vite配置

`vite.config.js` 文件包含：
- Vue插件配置
- 开发服务器配置
- API代理配置
- 构建优化配置

### 路由配置

`src/router/index.js` 包含所有路由定义和路由守卫。

### 状态管理

使用Pinia进行状态管理，当前有：
- User Store: 用户认证和信息管理

### API封装

`src/api/index.js` 包含：
- Axios实例配置
- 请求/响应拦截器
- 统一的API方法

## 开发指南

### 添加新页面

1. 在 `src/views/` 创建页面组件
2. 在 `src/router/index.js` 添加路由配置
3. 在导航菜单中添加链接

### 添加新API

在 `src/api/index.js` 中添加API方法：

```javascript
export const myAPI = {
  getData() {
    return api.get('/my-endpoint')
  }
}
```

### 样式规范

- 使用scoped样式避免污染
- 使用Element Plus的设计tokens
- 响应式断点：768px (mobile)

## 浏览器支持

- Chrome >= 87
- Firefox >= 78
- Safari >= 14
- Edge >= 88

## 许可证

MIT License

