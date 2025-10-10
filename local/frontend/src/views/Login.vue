<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-form-wrapper">
        <div class="form-header">
          <el-icon class="header-icon" :size="50"><UserFilled /></el-icon>
          <h2>用户登录</h2>
          <p>欢迎回来，请登录您的账号</p>
        </div>
        
        <el-form 
          :model="form" 
          :rules="rules" 
          ref="formRef"
          class="login-form"
          @submit.prevent="handleLogin"
        >
          <el-form-item prop="username">
            <el-input 
              v-model="form.username" 
              placeholder="请输入用户名"
              size="large"
              clearable
            >
              <template #prefix>
                <el-icon><User /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item prop="password">
            <el-input 
              v-model="form.password" 
              type="password"
              placeholder="请输入密码"
              size="large"
              show-password
              clearable
            >
              <template #prefix>
                <el-icon><Lock /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item>
            <el-button 
              type="primary" 
              @click="handleLogin" 
              :loading="loading"
              size="large"
              style="width: 100%"
            >
              {{ loading ? '登录中...' : '登录' }}
            </el-button>
          </el-form-item>
        </el-form>
        
        <div class="form-footer">
          <p>
            还没有账号？
            <router-link to="/register" class="link">立即注册</router-link>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../store'
import { authAPI } from '../api'

const router = useRouter()
const userStore = useUserStore()

const form = reactive({
  username: '',
  password: ''
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在3-20个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度至少6位', trigger: 'blur' }
  ]
}

const loading = ref(false)
const formRef = ref()

const handleLogin = async () => {
  try {
    await formRef.value.validate()
    
    loading.value = true
    
    const response = await authAPI.login(form)
    
    if (response.code === 200) {
      // 保存token和用户信息
      const { token, userId, username, email, avatar, role } = response.data
      userStore.login(token, { userId, username, email, avatar, role })
      
      ElMessage.success('登录成功')
      
      // 跳转到首页
      setTimeout(() => {
        router.push('/')
      }, 500)
    }
  } catch (error) {
    console.error('登录失败:', error)
    if (!error.response) {
      ElMessage.error(error.message || '登录失败')
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: calc(100vh - 140px);
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px 20px;
}

.login-container {
  width: 100%;
  max-width: 450px;
}

.login-form-wrapper {
  background: white;
  border-radius: 16px;
  padding: 50px 40px;
  box-shadow: 0 20px 60px rgba(0,0,0,0.3);
}

.form-header {
  text-align: center;
  margin-bottom: 40px;
}

.header-icon {
  color: #409EFF;
  margin-bottom: 15px;
}

.form-header h2 {
  margin: 0 0 10px 0;
  font-size: 28px;
  color: #333;
  font-weight: 600;
}

.form-header p {
  margin: 0;
  color: #666;
  font-size: 14px;
}

.login-form {
  margin-bottom: 20px;
}

.form-footer {
  text-align: center;
  padding-top: 20px;
  border-top: 1px solid #eee;
}

.form-footer p {
  margin: 0;
  color: #666;
  font-size: 14px;
}

.link {
  color: #409EFF;
  text-decoration: none;
  font-weight: 500;
}

.link:hover {
  text-decoration: underline;
}

@media (max-width: 768px) {
  .login-form-wrapper {
    padding: 40px 25px;
  }
}
</style>

