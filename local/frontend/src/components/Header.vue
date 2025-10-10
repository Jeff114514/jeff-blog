<template>
  <div class="header">
    <div class="container">
      <div class="logo-section">
        <h1 class="logo" @click="goHome">
          <el-icon><Notebook /></el-icon>
          个人博客
        </h1>
      </div>
      <nav class="nav">
        <router-link to="/">
          <el-icon><HomeFilled /></el-icon>
          首页
        </router-link>
        <router-link to="/articles">
          <el-icon><Document /></el-icon>
          文章
        </router-link>
        <router-link to="/ai">
          <el-icon><ChatDotRound /></el-icon>
          AI对话
        </router-link>
      </nav>
      <div class="user-section">
        <template v-if="isAuthenticated">
          <el-dropdown>
            <span class="user-dropdown">
              <el-avatar :size="35" :src="avatar">
                <el-icon><User /></el-icon>
              </el-avatar>
              <span class="username">{{ username }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="goCreate">
                  <el-icon><Edit /></el-icon>
                  写文章
                </el-dropdown-item>
                <el-dropdown-item @click="goProfile">
                  <el-icon><User /></el-icon>
                  个人中心
                </el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </template>
        <template v-else>
          <router-link to="/login" class="auth-link">登录</router-link>
          <router-link to="/register" class="auth-link primary">注册</router-link>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../store'

const router = useRouter()
const userStore = useUserStore()

const isAuthenticated = computed(() => userStore.isAuthenticated)
const username = computed(() => userStore.username)
const avatar = computed(() => userStore.avatar)

const goHome = () => {
  router.push('/')
}

const goCreate = () => {
  router.push('/create')
}

const goProfile = () => {
  ElMessage.info('个人中心功能开发中...')
}

const handleLogout = () => {
  userStore.logout()
  ElMessage.success('已退出登录')
  router.push('/')
}
</script>

<style scoped>
.header {
  background: linear-gradient(135deg, #409EFF 0%, #5CADFF 100%);
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  height: 60px;
}

.logo-section .logo {
  margin: 0;
  font-size: 22px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  color: white;
  transition: opacity 0.3s;
}

.logo:hover {
  opacity: 0.9;
}

.nav {
  display: flex;
  align-items: center;
  gap: 5px;
  flex: 1;
  justify-content: center;
}

.nav a {
  color: white;
  text-decoration: none;
  padding: 8px 16px;
  border-radius: 6px;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 15px;
}

.nav a:hover {
  background-color: rgba(255, 255, 255, 0.15);
}

.nav a.router-link-active {
  background-color: rgba(255, 255, 255, 0.25);
  font-weight: 500;
}

.user-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-dropdown {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 5px 12px;
  border-radius: 20px;
  transition: background-color 0.3s;
}

.user-dropdown:hover {
  background-color: rgba(255, 255, 255, 0.15);
}

.username {
  color: white;
  font-size: 14px;
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.auth-link {
  color: white;
  text-decoration: none;
  padding: 8px 20px;
  border-radius: 20px;
  transition: all 0.3s;
  font-size: 14px;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.auth-link:hover {
  background-color: rgba(255, 255, 255, 0.15);
  border-color: rgba(255, 255, 255, 0.5);
}

.auth-link.primary {
  background-color: white;
  color: #409EFF;
  border-color: white;
  font-weight: 500;
}

.auth-link.primary:hover {
  background-color: rgba(255, 255, 255, 0.9);
}
</style>

