<template>
  <div class="footer">
    <div class="container">
      <div class="footer-content">
        <div class="copyright">
          <p>&copy; 2024 个人博客系统. All Rights Reserved.</p>
          <p class="tech-stack">
            Powered by <strong>Spring Boot</strong> & <strong>Vue.js</strong>
          </p>
        </div>
        <div class="footer-links">
          <a href="https://github.com" target="_blank" rel="noopener">
            <el-icon><Link /></el-icon>
            GitHub
          </a>
          <span class="divider">|</span>
          <span class="status" :class="{ online: isOnline }">
            <el-icon><CircleCheck v-if="isOnline" /><CircleClose v-else /></el-icon>
            {{ isOnline ? '服务正常' : '服务异常' }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const isOnline = ref(true)

onMounted(() => {
  // 可以添加健康检查逻辑
})
</script>

<style scoped>
.footer {
  background-color: #ffffff;
  border-top: 1px solid #e8e8e8;
  padding: 20px 0;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.footer-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 15px;
}

.copyright {
  color: #666;
  font-size: 14px;
  line-height: 1.6;
}

.copyright p {
  margin: 0;
}

.tech-stack {
  font-size: 12px;
  color: #999;
  margin-top: 5px !important;
}

.tech-stack strong {
  color: #409EFF;
}

.footer-links {
  display: flex;
  align-items: center;
  gap: 15px;
  font-size: 14px;
}

.footer-links a {
  color: #666;
  text-decoration: none;
  display: flex;
  align-items: center;
  gap: 5px;
  transition: color 0.3s;
}

.footer-links a:hover {
  color: #409EFF;
}

.divider {
  color: #ddd;
}

.status {
  display: flex;
  align-items: center;
  gap: 5px;
  color: #999;
}

.status.online {
  color: #67C23A;
}

@media (max-width: 768px) {
  .footer-content {
    flex-direction: column;
    text-align: center;
  }
}
</style>

