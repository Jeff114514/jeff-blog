<template>
  <div class="article-list-page">
    <div class="page-header">
      <h1 class="page-title">
        <el-icon><Document /></el-icon>
        文章列表
      </h1>
      <el-button 
        v-if="isAuthenticated" 
        type="primary" 
        @click="createArticle"
      >
        <el-icon><Edit /></el-icon>
        写文章
      </el-button>
    </div>
    
    <div class="search-bar">
      <el-input 
        v-model="searchKeyword" 
        placeholder="搜索文章标题或内容" 
        size="large"
        clearable
        @keyup.enter="searchArticles"
        @clear="searchArticles"
      >
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
        <template #append>
          <el-button @click="searchArticles">搜索</el-button>
        </template>
      </el-input>
    </div>
    
    <el-skeleton :loading="loading" :rows="6" animated>
      <div v-if="articles.length > 0" class="articles-container">
        <div 
          v-for="article in articles" 
          :key="article.id" 
          class="article-card"
          @click="viewArticle(article.id)"
        >
          <div class="article-header">
            <h3 class="article-title">{{ article.title }}</h3>
            <el-tag v-if="article.category" type="primary">
              {{ article.category }}
            </el-tag>
          </div>
          <p class="article-summary">{{ article.summary || '暂无摘要...' }}</p>
          <div class="article-meta">
            <div class="meta-left">
              <span>
                <el-icon><User /></el-icon>
                作者ID: {{ article.authorId }}
              </span>
              <span>
                <el-icon><Clock /></el-icon>
                {{ formatDate(article.createdAt) }}
              </span>
            </div>
            <div class="meta-right">
              <span>
                <el-icon><View /></el-icon>
                {{ article.viewCount }}
              </span>
            </div>
          </div>
        </div>
      </div>
      <el-empty v-else description="暂无文章" />
    </el-skeleton>
    
    <el-pagination
      v-if="total > 0"
      v-model:current-page="currentPage"
      v-model:page-size="pageSize"
      :total="total"
      :page-sizes="[10, 20, 50]"
      layout="total, sizes, prev, pager, next, jumper"
      @current-change="handlePageChange"
      @size-change="handleSizeChange"
      style="margin-top: 30px; justify-content: center"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../store'
import { articleAPI } from '../api'

const router = useRouter()
const userStore = useUserStore()

const articles = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const searchKeyword = ref('')
const loading = ref(true)

const isAuthenticated = computed(() => userStore.isAuthenticated)

onMounted(() => {
  loadArticles()
})

const loadArticles = async () => {
  try {
    loading.value = true
    const response = await articleAPI.getArticles({
      page: currentPage.value,
      size: pageSize.value,
      keyword: searchKeyword.value
    })
    
    if (response.code === 200) {
      articles.value = response.data.records || response.data
      total.value = response.data.total || 0
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
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const handlePageChange = (page) => {
  currentPage.value = page
  loadArticles()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const handleSizeChange = (size) => {
  pageSize.value = size
  currentPage.value = 1
  loadArticles()
}

const searchArticles = () => {
  currentPage.value = 1
  loadArticles()
}

const createArticle = () => {
  router.push('/create')
}

const viewArticle = (id) => {
  router.push(`/article/${id}`)
}
</script>

<style scoped>
.article-list-page {
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
}

.page-title {
  margin: 0;
  font-size: 28px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 10px;
  color: #333;
}

.search-bar {
  margin-bottom: 30px;
}

.articles-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.article-card {
  background: white;
  padding: 28px;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid transparent;
}

.article-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0,0,0,0.12);
  border-color: #409EFF;
}

.article-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 15px;
  margin-bottom: 15px;
}

.article-title {
  margin: 0;
  font-size: 22px;
  font-weight: 600;
  color: #333;
  flex: 1;
  line-height: 1.4;
}

.article-summary {
  color: #666;
  line-height: 1.8;
  margin: 0 0 20px 0;
  font-size: 15px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.article-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 1px solid #f0f0f0;
}

.meta-left,
.meta-right {
  display: flex;
  gap: 20px;
  color: #999;
  font-size: 14px;
}

.meta-left span,
.meta-right span {
  display: flex;
  align-items: center;
  gap: 5px;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 15px;
  }
  
  .article-meta {
    flex-direction: column;
    gap: 10px;
    align-items: flex-start;
  }
}
</style>

