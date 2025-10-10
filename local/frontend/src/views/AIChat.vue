<template>
  <div class="ai-chat-page">
    <div class="page-header">
      <h1 class="page-title">
        <el-icon><ChatDotRound /></el-icon>
        AI智能对话
      </h1>
      <el-button @click="clearChat" :disabled="messages.length === 0">
        <el-icon><Delete /></el-icon>
        清空对话
      </el-button>
    </div>
    
    <div class="chat-container">
      <div class="chat-messages" ref="messagesContainer">
        <div v-if="messages.length === 0" class="empty-state">
          <el-icon :size="80" color="#409EFF"><ChatLineRound /></el-icon>
          <h3>开始与AI对话</h3>
          <p>你可以询问技术问题、寻求建议或进行日常对话</p>
          <div class="example-questions">
            <el-tag 
              v-for="(example, index) in exampleQuestions" 
              :key="index"
              @click="sendExample(example)"
              class="example-tag"
            >
              {{ example }}
            </el-tag>
          </div>
        </div>
        
        <div 
          v-for="(message, index) in messages" 
          :key="index" 
          :class="['message', message.role]"
        >
          <div class="message-wrapper">
            <div class="avatar">
              <el-avatar :size="40">
                <el-icon v-if="message.role === 'user'"><User /></el-icon>
                <el-icon v-else><Robot /></el-icon>
              </el-avatar>
            </div>
            <div class="content-wrapper">
              <div class="message-header">
                <span class="sender">{{ message.role === 'user' ? '你' : 'AI助手' }}</span>
                <span class="time">{{ message.time }}</span>
              </div>
              <div class="message-content" v-html="formatMessage(message.content)"></div>
            </div>
          </div>
        </div>
        
        <div v-if="isLoading" class="message assistant">
          <div class="message-wrapper">
            <div class="avatar">
              <el-avatar :size="40">
                <el-icon><Robot /></el-icon>
              </el-avatar>
            </div>
            <div class="content-wrapper">
              <div class="message-header">
                <span class="sender">AI助手</span>
              </div>
              <div class="loading-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div class="chat-input-area">
        <el-input
          v-model="inputMessage"
          placeholder="输入消息，按Enter发送，Shift+Enter换行..."
          type="textarea"
          :rows="3"
          :disabled="isLoading"
          @keydown.enter.exact.prevent="sendMessage"
          @keydown.enter.shift.exact.prevent="inputMessage += '\n'"
        />
        <div class="input-actions">
          <div class="input-tips">
            <el-icon><InfoFilled /></el-icon>
            <span>支持Markdown格式</span>
          </div>
          <el-button 
            type="primary" 
            @click="sendMessage" 
            :loading="isLoading"
            :disabled="!inputMessage.trim()"
          >
            <el-icon><Promotion /></el-icon>
            发送
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { marked } from 'marked'
import { aiAPI } from '../api'

const messages = ref([])
const inputMessage = ref('')
const isLoading = ref(false)
const messagesContainer = ref(null)

const exampleQuestions = [
  '什么是Vue.js？',
  '如何优化网站性能？',
  '解释一下Spring Boot的核心特性',
  '推荐一些学习前端的资源'
]

const formatMessage = (content) => {
  return marked.parse(content)
}

const getCurrentTime = () => {
  const now = new Date()
  return now.toLocaleTimeString('zh-CN', { 
    hour: '2-digit', 
    minute: '2-digit' 
  })
}

const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

const sendMessage = async () => {
  const message = inputMessage.value.trim()
  
  if (!message) {
    ElMessage.warning('请输入消息内容')
    return
  }
  
  // 添加用户消息
  messages.value.push({
    role: 'user',
    content: message,
    time: getCurrentTime()
  })
  
  inputMessage.value = ''
  scrollToBottom()
  
  // 调用AI服务
  isLoading.value = true
  
  try {
    const response = await aiAPI.chat(message)
    
    if (response.code === 200) {
      messages.value.push({
        role: 'assistant',
        content: response.data.message || response.data,
        time: getCurrentTime()
      })
    } else {
      messages.value.push({
        role: 'assistant',
        content: '抱歉，我现在无法回答。请稍后再试。',
        time: getCurrentTime()
      })
    }
  } catch (error) {
    console.error('AI服务调用失败:', error)
    messages.value.push({
      role: 'assistant',
      content: '抱歉，AI服务暂时不可用。请确保本地AI服务（如Ollama）正在运行。',
      time: getCurrentTime()
    })
  } finally {
    isLoading.value = false
    scrollToBottom()
  }
}

const sendExample = (example) => {
  inputMessage.value = example
  sendMessage()
}

const clearChat = () => {
  messages.value = []
  ElMessage.success('对话已清空')
}
</script>

<style scoped>
.ai-chat-page {
  max-width: 1200px;
  margin: 0 auto;
  height: calc(100vh - 140px);
  display: flex;
  flex-direction: column;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
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

.chat-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  overflow: hidden;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 30px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #666;
  text-align: center;
}

.empty-state h3 {
  margin: 20px 0 10px 0;
  font-size: 24px;
  color: #333;
}

.empty-state p {
  margin: 0 0 30px 0;
  font-size: 16px;
}

.example-questions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  justify-content: center;
  max-width: 600px;
}

.example-tag {
  cursor: pointer;
  transition: all 0.3s;
}

.example-tag:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.message {
  display: flex;
  animation: fadeIn 0.3s ease-in;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.message.user {
  justify-content: flex-end;
}

.message-wrapper {
  display: flex;
  gap: 12px;
  max-width: 80%;
}

.message.user .message-wrapper {
  flex-direction: row-reverse;
}

.avatar {
  flex-shrink: 0;
}

.content-wrapper {
  flex: 1;
}

.message-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
  font-size: 14px;
  color: #999;
}

.message.user .message-header {
  justify-content: flex-end;
}

.sender {
  font-weight: 500;
  color: #666;
}

.message-content {
  padding: 12px 16px;
  border-radius: 12px;
  line-height: 1.6;
  word-wrap: break-word;
}

.message.user .message-content {
  background: #409EFF;
  color: white;
  border-bottom-right-radius: 4px;
}

.message.assistant .message-content {
  background: #f5f7fa;
  color: #333;
  border-bottom-left-radius: 4px;
}

.message-content :deep(p) {
  margin: 0 0 8px 0;
}

.message-content :deep(p:last-child) {
  margin-bottom: 0;
}

.message-content :deep(code) {
  background-color: rgba(0,0,0,0.1);
  padding: 2px 6px;
  border-radius: 4px;
  font-family: monospace;
}

.message.user .message-content :deep(code) {
  background-color: rgba(255,255,255,0.2);
}

.message-content :deep(pre) {
  background-color: #2d2d2d;
  color: #f8f8f2;
  padding: 12px;
  border-radius: 6px;
  overflow-x: auto;
  margin: 8px 0;
}

.message-content :deep(pre code) {
  background: none;
  padding: 0;
  color: inherit;
}

.loading-indicator {
  display: flex;
  gap: 6px;
  padding: 12px 16px;
  background: #f5f7fa;
  border-radius: 12px;
  border-bottom-left-radius: 4px;
}

.loading-indicator span {
  width: 8px;
  height: 8px;
  background: #409EFF;
  border-radius: 50%;
  animation: bounce 1.4s infinite ease-in-out both;
}

.loading-indicator span:nth-child(1) {
  animation-delay: -0.32s;
}

.loading-indicator span:nth-child(2) {
  animation-delay: -0.16s;
}

@keyframes bounce {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}

.chat-input-area {
  border-top: 1px solid #eee;
  padding: 20px;
  background: #fafafa;
}

.input-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 12px;
}

.input-tips {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #999;
  font-size: 13px;
}

@media (max-width: 768px) {
  .chat-messages {
    padding: 20px 15px;
  }
  
  .message-wrapper {
    max-width: 90%;
  }
}
</style>

