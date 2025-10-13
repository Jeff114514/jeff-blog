# 后端Dockerfile - 临时解决方案
# 注意：需要手动构建后端项目并将jar文件放入target目录

FROM swr.cn-north-1.myhuaweicloud.com/library/openjdk:21-jre-slim

# 设置工作目录
WORKDIR /app

# 复制预构建的jar包（需要手动构建）
COPY target/blog-backend-1.0.0.jar app.jar

# 暴露端口
EXPOSE 8080

# 设置环境变量
ENV TZ=Asia/Shanghai
ENV JAVA_OPTS="-Xms256m -Xmx512m"

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

