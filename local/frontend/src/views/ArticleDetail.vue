<template>
  <div class="article-detail-page">
    <el-skeleton :loading="loading" :rows="10" animated>
      <div v-if="article" class="article-container">
        <div class="article-header">
          <h1 class="article-title">{{ article.title }}</h1>
          <div class="article-meta">
            <div class="meta-item">
              <el-icon><User /></el-icon>
              <span>作者ID: {{ article.authorId }}</span>
            </div>
            <div class="meta-item">
              <el-icon><Clock /></el-icon>
              <span>{{ formatDate(article.createdAt) }}</span>
            </div>
            <div class="meta-item">
              <el-icon><View /></el-icon>
              <span>{{ article.viewCount }} 次阅读</span>
            </div>
            <el-tag v-if="article.category" type="primary">
              {{ article.category }}
            </el-tag>
          </div>
        </div>
        
        <el-divider />
        
        <div class="article-content" v-html="renderedContent"></div>
        
        <el-divider />
        
        <div class="article-footer">
          <el-button @click="goBack">
            <el-icon><Back /></el-icon>
            返回列表
          </el-button>
          <div v-if="canEdit" class="edit-actions">
            <el-button type="primary" @click="editArticle">
              <el-icon><Edit /></el-icon>
              编辑
            </el-button>
            <el-popconfirm
              title="确定要删除这篇文章吗？"
              @confirm="deleteArticle"
            >
              <template #reference>
                <el-button type="danger">
                  <el-icon><Delete /></el-icon>
                  删除
                </el-button>
              </template>
            </el-popconfirm>
          </div>
        </div>
      </div>
      <el-empty v-else description="文章不存在" />
    </el-skeleton>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { marked } from 'marked'
import hljs from 'highlight.js'
import 'highlight.js/styles/github.css'
import { useUserStore } from '../store'
import { articleAPI } from '../api'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const article = ref(null)
const renderedContent = ref('')
const loading = ref(true)

const canEdit = computed(() => {
  return userStore.isAuthenticated && 
         article.value && 
         article.value.authorId === userStore.userId
})

onMounted(async () => {
  await loadArticle()
  configureMarked()
})

const configureMarked = () => {
  marked.setOptions({
    highlight: function(code, lang) {
      if (lang && hljs.getLanguage(lang)) {
        return hljs.highlight(code, { language: lang }).value
      }
      return hljs.highlightAuto(code).value
    },
    breaks: true,
    gfm: true
  })
}

const loadArticle = async () => {
  try {
    loading.value = true
    const response = await articleAPI.getArticle(route.params.id)
    
    if (response.code === 200) {
      article.value = response.data
      renderedContent.value = marked.parse(article.value.content || '')
    }
  } catch (error) {
    console.error('获取文章详情失败:', error)
    ElMessage.error('获取文章详情失败')
  } finally {
    loading.value = false
  }
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const goBack = () => {
  router.push('/articles')
}

const editArticle = () => {
  ElMessage.info('编辑功能开发中...')
}

const deleteArticle = async () => {
  try {
    const response = await articleAPI.deleteArticle(article.value.id, userStore.userId)
    if (response.code === 200) {
      ElMessage.success('文章已删除')
      router.push('/articles')
    }
  } catch (error) {
    console.error('删除文章失败:', error)
    ElMessage.error('删除文章失败')
  }
}
</script>

<style scoped>
.article-detail-page {
  max-width: 900px;
  margin: 0 auto;
}

.article-container {
  background: white;
  border-radius: 12px;
  padding: 40px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
}

.article-header {
  margin-bottom: 30px;
}

.article-title {
  font-size: 36px;
  font-weight: 700;
  color: #333;
  margin: 0 0 20px 0;
  line-height: 1.4;
}

.article-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  align-items: center;
  color: #999;
  font-size: 14px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
}

.article-content {
  font-size: 16px;
  line-height: 1.8;
  color: #333;
  min-height: 200px;
}

.article-content :deep(h1),
.article-content :deep(h2),
.article-content :deep(h3) {
  margin-top: 1.8em;
  margin-bottom: 0.8em;
  font-weight: 600;
  color: #333;
}

.article-content :deep(h1) { font-size: 2em; }
.article-content :deep(h2) { font-size: 1.6em; }
.article-content :deep(h3) { font-size: 1.3em; }

.article-content :deep(p) {
  margin-bottom: 1.2em;
}

.article-content :deep(a) {
  color: #409EFF;
  text-decoration: none;
}

.article-content :deep(a:hover) {
  text-decoration: underline;
}

.article-content :deep(code) {
  background-color: #f5f7fa;
  padding: 3px 6px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 0.9em;
  color: #e96900;
}

.article-content :deep(pre) {
  background-color: #f6f8fa;
  padding: 16px;
  border-radius: 6px;
  overflow-x: auto;
  margin: 1.5em 0;
  border: 1px solid #e1e4e8;
}

.article-content :deep(pre code) {
  background: none;
  padding: 0;
  color: inherit;
  font-size: 14px;
  line-height: 1.6;
}

.article-content :deep(blockquote) {
  border-left: 4px solid #409EFF;
  padding-left: 16px;
  margin: 1.5em 0;
  color: #666;
  background-color: #f9f9f9;
  padding: 12px 16px;
  border-radius: 0 4px 4px 0;
}

.article-content :deep(img) {
  max-width: 100%;
  border-radius: 8px;
  margin: 1.5em 0;
}

.article-content :deep(ul), 
.article-content :deep(ol) {
  padding-left: 2em;
  margin: 1em 0;
}

.article-content :deep(li) {
  margin: 0.5em 0;
}

.article-content :deep(table) {
  border-collapse: collapse;
  width: 100%;
  margin: 1.5em 0;
}

.article-content :deep(table th),
.article-content :deep(table td) {
  border: 1px solid #ddd;
  padding: 10px;
  text-align: left;
}

.article-content :deep(table th) {
  background-color: #f5f5f5;
  font-weight: 600;
}

.article-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 30px;
}

.edit-actions {
  display: flex;
  gap: 10px;
}

@media (max-width: 768px) {
  .article-container {
    padding: 25px 20px;
  }
  
  .article-title {
    font-size: 28px;
  }
  
  .article-footer {
    flex-direction: column;
    gap: 15px;
  }
  
  .edit-actions {
    width: 100%;
    justify-content: center;
  }
}
</style>

