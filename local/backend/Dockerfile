# 后端Dockerfile
FROM openjdk:11-jre-slim

# 设置工作目录
WORKDIR /app

# 复制jar包
COPY target/blog-backend-1.0.0.jar app.jar

# 暴露端口
EXPOSE 8080

# 设置环境变量
ENV TZ=Asia/Shanghai
ENV JAVA_OPTS="-Xms256m -Xmx512m"

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

