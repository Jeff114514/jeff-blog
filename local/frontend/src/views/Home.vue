<template>
  <div class="home">
    <div class="hero">
      <div class="hero-content">
        <h1 class="hero-title">
          <el-icon class="title-icon"><Notebook /></el-icon>
          欢迎来到我的个人博客
        </h1>
        <p class="hero-subtitle">分享技术，记录生活，探索AI的无限可能</p>
        <div class="hero-actions">
          <el-button type="primary" size="large" @click="goArticles">
            <el-icon><Reading /></el-icon>
            浏览文章
          </el-button>
          <el-button size="large" @click="goAI">
            <el-icon><ChatDotRound /></el-icon>
            体验AI对话
          </el-button>
        </div>
      </div>
    </div>
    
    <div class="features">
      <h2 class="section-title">功能特性</h2>
      <div class="feature-grid">
        <div class="feature-card">
          <div class="feature-icon">
            <el-icon color="#409EFF" :size="40"><Document /></el-icon>
          </div>
          <h3>技术博客</h3>
          <p>分享编程技术、开发经验、学习笔记</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">
            <el-icon color="#67C23A" :size="40"><ChatDotRound /></el-icon>
          </div>
          <h3>AI对话</h3>
          <p>与本地大模型进行智能对话，提供技术咨询</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">
            <el-icon color="#E6A23C" :size="40"><Connection /></el-icon>
          </div>
          <h3>内网穿透</h3>
          <p>通过FRP实现内网服务外网访问</p>
        </div>
      </div>
    </div>
    
    <div class="recent-posts">
      <div class="section-header">
        <h2 class="section-title">最新文章</h2>
        <el-button link @click="goArticles">
          查看更多
          <el-icon><ArrowRight /></el-icon>
        </el-button>
      </div>
      
      <el-skeleton :loading="loading" :rows="5" animated>
        <div v-if="recentArticles.length > 0" class="posts-grid">
          <div 
            v-for="article in recentArticles" 
            :key="article.id" 
            class="post-card"
            @click="goArticle(article.id)"
          >
            <h3 class="post-title">{{ article.title }}</h3>
            <p class="post-summary">{{ article.summary || '暂无摘要' }}</p>
            <div class="post-meta">
              <span>
                <el-icon><Clock /></el-icon>
                {{ formatDate(article.createdAt) }}
              </span>
              <span>
                <el-icon><View /></el-icon>
                {{ article.viewCount }}
              </span>
              <el-tag v-if="article.category" size="small" type="primary">
                {{ article.category }}
              </el-tag>
            </div>
          </div>
        </div>
        <el-empty v-else description="暂无文章" />
      </el-skeleton>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { articleAPI } from '../api'

const router = useRouter()
const recentArticles = ref([])
const loading = ref(true)

onMounted(async () => {
  await loadRecentArticles()
})

const loadRecentArticles = async () => {
  try {
    loading.value = true
    const response = await articleAPI.getArticleList()
    if (response.code === 200) {
      recentArticles.value = response.data.slice(0, 6)
    }
  } catch (error) {
    console.error('获取文章列表失败:', error)
    ElMessage.error('获取文章列表失败')
  } finally {
    loading.value = false
  }
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}

const goArticles = () => {
  router.push('/articles')
}

const goAI = () => {
  router.push('/ai')
}

const goArticle = (id) => {
  router.push(`/article/${id}`)
}
</script>

<style scoped>
.home {
  max-width: 1200px;
  margin: 0 auto;
}

.hero {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  padding: 80px 40px;
  margin-bottom: 60px;
  text-align: center;
  color: white;
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
}

.hero-content {
  max-width: 800px;
  margin: 0 auto;
}

.hero-title {
  font-size: 48px;
  font-weight: 700;
  margin: 0 0 20px 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 15px;
}

.title-icon {
  font-size: 50px;
}

.hero-subtitle {
  font-size: 20px;
  margin: 0 0 40px 0;
  opacity: 0.95;
  line-height: 1.6;
}

.hero-actions {
  display: flex;
  gap: 20px;
  justify-content: center;
}

.section-title {
  font-size: 32px;
  font-weight: 600;
  margin-bottom: 30px;
  text-align: center;
  color: #333;
}

.features {
  margin-bottom: 60px;
}

.feature-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 30px;
}

.feature-card {
  background: white;
  padding: 40px 30px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  text-align: center;
  transition: all 0.3s;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(0,0,0,0.12);
}

.feature-icon {
  margin-bottom: 20px;
}

.feature-card h3 {
  font-size: 20px;
  margin: 0 0 15px 0;
  color: #333;
}

.feature-card p {
  color: #666;
  line-height: 1.6;
  margin: 0;
}

.recent-posts {
  margin-bottom: 40px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.section-header .section-title {
  margin: 0;
  text-align: left;
}

.posts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 24px;
}

.post-card {
  background: white;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  cursor: pointer;
  transition: all 0.3s;
}

.post-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(0,0,0,0.12);
}

.post-title {
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 12px 0;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.post-summary {
  color: #666;
  line-height: 1.6;
  margin: 0 0 16px 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  font-size: 14px;
}

.post-meta {
  display: flex;
  align-items: center;
  gap: 16px;
  color: #999;
  font-size: 13px;
}

.post-meta span {
  display: flex;
  align-items: center;
  gap: 4px;
}

@media (max-width: 768px) {
  .hero {
    padding: 50px 20px;
  }
  
  .hero-title {
    font-size: 32px;
  }
  
  .hero-subtitle {
    font-size: 16px;
  }
  
  .hero-actions {
    flex-direction: column;
  }
  
  .posts-grid {
    grid-template-columns: 1fr;
  }
}
</style>

