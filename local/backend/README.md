# 博客后端系统

基于Spring Boot 2.7的博客后端服务。

## 技术栈

- Spring Boot 2.7.14
- Spring Security
- MyBatis Plus 3.5.3
- MySQL 8.0
- JWT认证
- Lombok

## 项目结构

```
backend/
├── src/main/java/com/blog/
│   ├── BlogApplication.java     # 主启动类
│   ├── common/                  # 公共类
│   │   └── Result.java         # 统一返回结果
│   ├── config/                  # 配置类
│   │   ├── CorsConfig.java     # 跨域配置
│   │   ├── MyBatisPlusConfig.java  # MyBatis配置
│   │   └── SecurityConfig.java # 安全配置
│   ├── controller/              # 控制器
│   │   ├── AIController.java
│   │   ├── ArticleController.java
│   │   └── AuthController.java
│   ├── dto/                     # 数据传输对象
│   ├── entity/                  # 实体类
│   ├── mapper/                  # MyBatis Mapper
│   ├── service/                 # 服务接口
│   │   └── impl/               # 服务实现
│   └── util/                    # 工具类
│       └── JwtUtil.java
├── src/main/resources/
│   ├── application.yml         # 配置文件
│   └── mapper/                 # MyBatis XML
└── pom.xml                     # Maven配置
```

## 快速开始

### 1. 环境要求

- JDK 11+
- Maven 3.6+
- MySQL 8.0+

### 2. 数据库配置

创建数据库：

```sql
CREATE DATABASE blog_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE blog_db;

-- 用户表
CREATE TABLE `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `avatar` VARCHAR(255),
  `status` INT DEFAULT 1,
  `role` VARCHAR(20) DEFAULT 'user',
  `created_at` DATETIME,
  `updated_at` DATETIME,
  `deleted` INT DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 文章表
CREATE TABLE `articles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `content` TEXT NOT NULL,
  `summary` VARCHAR(500),
  `author_id` BIGINT NOT NULL,
  `category` VARCHAR(50),
  `tags` VARCHAR(255),
  `status` INT DEFAULT 1,
  `view_count` INT DEFAULT 0,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  `deleted` INT DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_author_id` (`author_id`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 评论表
CREATE TABLE `comments` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `article_id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  `content` TEXT NOT NULL,
  `parent_id` BIGINT,
  `status` INT DEFAULT 1,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  `deleted` INT DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_article_id` (`article_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 3. 修改配置

编辑 `src/main/resources/application.yml`，修改数据库连接信息：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/blog_db
    username: your_username
    password: your_password
```

### 4. 构建运行

```bash
# 编译打包
mvn clean package -DskipTests

# 运行
java -jar target/blog-backend-1.0.0.jar

# 或者使用Maven运行
mvn spring-boot:run
```

### 5. 访问服务

- API地址: http://localhost:8080
- 健康检查: http://localhost:8080/api/auth/login

## API文档

### 认证接口

#### 用户注册
```
POST /api/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "123456"
}
```

#### 用户登录
```
POST /api/auth/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "123456"
}
```

### 文章接口

#### 获取文章列表
```
GET /api/articles?page=1&size=10&category=技术&keyword=搜索关键词
```

#### 获取文章详情
```
GET /api/articles/{id}
```

#### 创建文章
```
POST /api/articles?userId=1
Content-Type: application/json

{
  "title": "文章标题",
  "content": "文章内容",
  "summary": "文章摘要",
  "category": "技术",
  "tags": "Spring,Java",
  "status": 1
}
```

### AI对话接口

#### AI对话
```
POST /api/ai/chat
Content-Type: application/json

{
  "message": "你好"
}
```

## Docker部署

```bash
# 构建镜像
docker build -t blog-backend:1.0.0 .

# 运行容器
docker run -d -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/blog_db \
  -e SPRING_DATASOURCE_USERNAME=root \
  -e SPRING_DATASOURCE_PASSWORD=password \
  --name blog-backend \
  blog-backend:1.0.0
```

## 开发说明

### 添加新功能

1. 在 `entity` 包中创建实体类
2. 在 `mapper` 包中创建Mapper接口
3. 在 `service` 包中创建服务接口和实现
4. 在 `controller` 包中创建控制器
5. 在 `dto` 包中创建请求/响应DTO

### 测试

```bash
# 运行测试
mvn test

# 跳过测试构建
mvn clean package -DskipTests
```

## 故障排查

1. 端口占用: 修改 `application.yml` 中的 `server.port`
2. 数据库连接失败: 检查数据库配置和网络连接
3. AI服务无法连接: 确保本地AI服务（如Ollama）正在运行

## 许可证

MIT License

