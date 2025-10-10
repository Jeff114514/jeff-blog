import axios from 'axios'
import { ElMessage } from 'element-plus'

// API基础URL
const API_BASE_URL = import.meta.env.VITE_API_URL || '/api'

// 创建axios实例
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 请求拦截器
api.interceptors.request.use(
  config => {
    // 添加token
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => {
    console.error('请求错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
api.interceptors.response.use(
  response => {
    const res = response.data
    
    // 如果返回的状态码不是200，则显示错误信息
    if (res.code !== 200) {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message || '请求失败'))
    }
    
    return res
  },
  error => {
    console.error('响应错误:', error)
    
    if (error.response) {
      const status = error.response.status
      
      switch (status) {
        case 401:
          ElMessage.error('未登录或登录已过期，请重新登录')
          localStorage.removeItem('token')
          localStorage.removeItem('userInfo')
          window.location.href = '/login'
          break
        case 403:
          ElMessage.error('没有权限访问')
          break
        case 404:
          ElMessage.error('请求的资源不存在')
          break
        case 500:
          ElMessage.error('服务器错误')
          break
        default:
          ElMessage.error(error.response.data.message || '请求失败')
      }
    } else if (error.request) {
      ElMessage.error('网络错误，请检查网络连接')
    } else {
      ElMessage.error('请求配置错误')
    }
    
    return Promise.reject(error)
  }
)

// API方法
export const authAPI = {
  // 登录
  login(data) {
    return api.post('/auth/login', data)
  },
  
  // 注册
  register(data) {
    return api.post('/auth/register', data)
  },
  
  // 获取用户信息
  getProfile(userId) {
    return api.get(`/auth/profile/${userId}`)
  }
}

export const articleAPI = {
  // 获取文章列表
  getArticles(params) {
    return api.get('/articles', { params })
  },
  
  // 获取所有文章
  getArticleList() {
    return api.get('/articles/list')
  },
  
  // 获取文章详情
  getArticle(id) {
    return api.get(`/articles/${id}`)
  },
  
  // 创建文章
  createArticle(data, userId) {
    return api.post('/articles', data, { params: { userId } })
  },
  
  // 更新文章
  updateArticle(id, data, userId) {
    return api.put(`/articles/${id}`, data, { params: { userId } })
  },
  
  // 删除文章
  deleteArticle(id, userId) {
    return api.delete(`/articles/${id}`, { params: { userId } })
  }
}

export const aiAPI = {
  // AI对话
  chat(message) {
    return api.post('/ai/chat', { message })
  },
  
  // 检查AI服务状态
  checkStatus() {
    return api.get('/ai/status')
  }
}

export default api

