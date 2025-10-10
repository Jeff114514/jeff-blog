<template>
  <div id="app">
    <el-container>
      <el-header>
        <Header />
      </el-header>
      <el-main>
        <router-view />
      </el-main>
      <el-footer>
        <Footer />
      </el-footer>
    </el-container>
  </div>
</template>

<script setup>
import Header from './components/Header.vue'
import Footer from './components/Footer.vue'
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', Arial, sans-serif;
  background-color: #f5f5f5;
}

#app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.el-container {
  min-height: 100vh;
  flex-direction: column;
}

.el-header {
  background-color: #409EFF;
  color: #fff;
  padding: 0;
  height: auto !important;
}

.el-main {
  flex: 1;
  padding: 20px;
  min-height: calc(100vh - 60px - 60px);
}

.el-footer {
  background-color: #f5f5f5;
  color: #666;
  text-align: center;
  line-height: 60px;
  padding: 0;
  height: 60px !important;
  border-top: 1px solid #e0e0e0;
}
</style>

