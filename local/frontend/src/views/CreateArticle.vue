<template>
  <div class="create-article-page">
    <div class="page-header">
      <h1 class="page-title">
        <el-icon><Edit /></el-icon>
        写文章
      </h1>
    </div>
    
    <div class="create-form-container">
      <el-form :model="form" :rules="rules" ref="formRef" label-position="top">
        <el-form-item label="文章标题" prop="title">
          <el-input 
            v-model="form.title" 
            placeholder="请输入文章标题"
            size="large"
            maxlength="100"
            show-word-limit
          />
        </el-form-item>
        
        <el-form-item label="文章摘要" prop="summary">
          <el-input 
            v-model="form.summary" 
            placeholder="请输入文章摘要（选填）"
            type="textarea"
            :rows="3"
            maxlength="200"
            show-word-limit
          />
        </el-form-item>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="分类" prop="category">
              <el-select 
                v-model="form.category" 
                placeholder="选择分类"
                style="width: 100%"
                size="large"
              >
                <el-option label="技术" value="技术"></el-option>
                <el-option label="生活" value="生活"></el-option>
                <el-option label="随笔" value="随笔"></el-option>
                <el-option label="教程" value="教程"></el-option>
                <el-option label="其他" value="其他"></el-option>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="标签" prop="tags">
              <el-input 
                v-model="form.tags" 
                placeholder="多个标签用逗号分隔"
                size="large"
              />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="文章内容（支持Markdown）" prop="content">
          <el-input 
            v-model="form.content" 
            placeholder="请输入文章内容，支持Markdown格式"
            type="textarea"
            :rows="20"
            :autosize="{ minRows: 20, maxRows: 40 }"
          />
        </el-form-item>
        
        <el-form-item>
          <div class="action-buttons">
            <el-button 
              type="primary" 
              size="large"
              @click="submitArticle(1)" 
              :loading="loading"
            >
              <el-icon><Check /></el-icon>
              发布文章
            </el-button>
            <el-button 
              size="large"
              @click="submitArticle(0)" 
              :loading="loading"
            >
              <el-icon><DocumentCopy /></el-icon>
              保存草稿
            </el-button>
            <el-button 
              size="large"
              @click="previewArticle"
            >
              <el-icon><View /></el-icon>
              预览
            </el-button>
            <el-button 
              size="large"
              @click="goBack"
            >
              <el-icon><Close /></el-icon>
              取消
            </el-button>
          </div>
        </el-form-item>
      </el-form>
    </div>
    
    <!-- 预览对话框 -->
    <el-dialog 
      v-model="previewVisible" 
      title="文章预览" 
      width="80%"
      :close-on-click-modal="false"
    >
      <div class="preview-header">
        <h1>{{ form.title || '未命名文章' }}</h1>
        <div class="preview-meta">
          <el-tag v-if="form.category" type="primary">{{ form.category }}</el-tag>
          <span v-if="form.tags">标签: {{ form.tags }}</span>
        </div>
      </div>
      <el-divider />
      <div class="preview-content" v-html="previewContent"></div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { marked } from 'marked'
import { useUserStore } from '../store'
import { articleAPI } from '../api'

const router = useRouter()
const userStore = useUserStore()

const form = reactive({
  title: '',
  summary: '',
  content: '',
  category: '',
  tags: '',
  status: 1
})

const rules = {
  title: [
    { required: true, message: '请输入文章标题', trigger: 'blur' },
    { min: 3, message: '标题至少3个字符', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入文章内容', trigger: 'blur' },
    { min: 10, message: '内容至少10个字符', trigger: 'blur' }
  ]
}

const loading = ref(false)
const previewVisible = ref(false)
const previewContent = ref('')
const formRef = ref()

const submitArticle = async (status) => {
  try {
    await formRef.value.validate()
    
    if (!userStore.isAuthenticated) {
      ElMessage.error('请先登录')
      router.push('/login')
      return
    }
    
    loading.value = true
    form.status = status
    
    const response = await articleAPI.createArticle(form, userStore.userId)
    
    if (response.code === 200) {
      ElMessage.success(status === 1 ? '文章发布成功' : '草稿保存成功')
      setTimeout(() => {
        router.push('/articles')
      }, 1000)
    }
  } catch (error) {
    console.error('提交失败:', error)
    if (!error.response) {
      ElMessage.error(error.message || '提交失败')
    }
  } finally {
    loading.value = false
  }
}

const previewArticle = () => {
  if (!form.content.trim()) {
    ElMessage.warning('请先输入文章内容')
    return
  }
  
  previewContent.value = marked.parse(form.content)
  previewVisible.value = true
}

const goBack = () => {
  router.push('/articles')
}
</script>

<style scoped>
.create-article-page {
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
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

.create-form-container {
  background: white;
  border-radius: 12px;
  padding: 40px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
}

.action-buttons {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.preview-header h1 {
  margin: 0 0 15px 0;
  font-size: 32px;
  color: #333;
}

.preview-meta {
  display: flex;
  gap: 15px;
  align-items: center;
  color: #666;
  font-size: 14px;
}

.preview-content {
  font-size: 16px;
  line-height: 1.8;
  color: #333;
}

.preview-content :deep(h1),
.preview-content :deep(h2),
.preview-content :deep(h3) {
  margin-top: 1.5em;
  margin-bottom: 0.8em;
}

.preview-content :deep(p) {
  margin-bottom: 1em;
}

.preview-content :deep(code) {
  background-color: #f5f5f5;
  padding: 3px 6px;
  border-radius: 4px;
  font-family: monospace;
}

.preview-content :deep(pre) {
  background-color: #f6f8fa;
  padding: 16px;
  border-radius: 6px;
  overflow-x: auto;
  margin: 1.5em 0;
}

.preview-content :deep(pre code) {
  background: none;
  padding: 0;
}

@media (max-width: 768px) {
  .create-form-container {
    padding: 25px 20px;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .action-buttons .el-button {
    width: 100%;
  }
}
</style>

