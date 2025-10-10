<template>
  <div class="register-page">
    <div class="register-container">
      <div class="register-form-wrapper">
        <div class="form-header">
          <el-icon class="header-icon" :size="50"><CirclePlus /></el-icon>
          <h2>用户注册</h2>
          <p>创建您的账号，开始精彩之旅</p>
        </div>
        
        <el-form 
          :model="form" 
          :rules="rules" 
          ref="formRef"
          class="register-form"
        >
          <el-form-item prop="username">
            <el-input 
              v-model="form.username" 
              placeholder="请输入用户名（3-20字符）"
              size="large"
              clearable
            >
              <template #prefix>
                <el-icon><User /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item prop="email">
            <el-input 
              v-model="form.email" 
              placeholder="请输入邮箱"
              size="large"
              clearable
            >
              <template #prefix>
                <el-icon><Message /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item prop="password">
            <el-input 
              v-model="form.password" 
              type="password"
              placeholder="请输入密码（至少6位）"
              size="large"
              show-password
              clearable
            >
              <template #prefix>
                <el-icon><Lock /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item prop="confirmPassword">
            <el-input 
              v-model="form.confirmPassword" 
              type="password"
              placeholder="请再次输入密码"
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
              @click="handleRegister" 
              :loading="loading"
              size="large"
              style="width: 100%"
            >
              {{ loading ? '注册中...' : '注册' }}
            </el-button>
          </el-form-item>
        </el-form>
        
        <div class="form-footer">
          <p>
            已有账号？
            <router-link to="/login" class="link">立即登录</router-link>
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
import { authAPI } from '../api'

const router = useRouter()

const form = reactive({
  username: '',
  email: '',
  password: '',
  confirmPassword: ''
})

const validateConfirmPassword = (rule, value, callback) => {
  if (value !== form.password) {
    callback(new Error('两次输入密码不一致'))
  } else {
    callback()
  }
}

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在3-20个字符', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9_]+$/, message: '用户名只能包含字母、数字和下划线', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度在6-20个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const loading = ref(false)
const formRef = ref()

const handleRegister = async () => {
  try {
    await formRef.value.validate()
    
    loading.value = true
    
    const { confirmPassword, ...registerData } = form
    const response = await authAPI.register(registerData)
    
    if (response.code === 200) {
      ElMessage.success('注册成功，请登录')
      setTimeout(() => {
        router.push('/login')
      }, 1000)
    }
  } catch (error) {
    console.error('注册失败:', error)
    if (!error.response) {
      ElMessage.error(error.message || '注册失败')
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.register-page {
  min-height: calc(100vh - 140px);
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px 20px;
}

.register-container {
  width: 100%;
  max-width: 450px;
}

.register-form-wrapper {
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
  color: #67C23A;
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

.register-form {
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
  .register-form-wrapper {
    padding: 40px 25px;
  }
}
</style>

