import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    userInfo: JSON.parse(localStorage.getItem('userInfo') || '{}')
  }),
  
  getters: {
    isAuthenticated: (state) => !!state.token,
    userId: (state) => state.userInfo.userId || null,
    username: (state) => state.userInfo.username || '',
    email: (state) => state.userInfo.email || '',
    avatar: (state) => state.userInfo.avatar || '',
    role: (state) => state.userInfo.role || 'user'
  },
  
  actions: {
    setToken(token) {
      this.token = token
      localStorage.setItem('token', token)
    },
    
    setUserInfo(userInfo) {
      this.userInfo = userInfo
      localStorage.setItem('userInfo', JSON.stringify(userInfo))
    },
    
    login(token, userInfo) {
      this.setToken(token)
      this.setUserInfo(userInfo)
    },
    
    logout() {
      this.token = ''
      this.userInfo = {}
      localStorage.removeItem('token')
      localStorage.removeItem('userInfo')
    }
  }
})

