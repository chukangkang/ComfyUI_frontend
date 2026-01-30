# ComfyUI API 使用示例

实际的代码示例展示如何在 ComfyUI 前端项目中使用各种 API。

## 目录

1. [注册表 API 示例](#注册表-api-示例)
2. [客户事件 API 示例](#客户事件-api-示例)
3. [工作区 API 示例](#工作区-api-示例)
4. [后端 API 示例](#后端-api-示例)
5. [WebSocket 示例](#websocket-示例)
6. [错误处理](#错误处理)

---

## 注册表 API 示例

### 示例 1: 搜索节点包

```typescript
<script setup lang="ts">
import { ref, computed } from 'vue'
import { useComfyRegistryService } from '@/services/comfyRegistryService'

const service = useComfyRegistryService()
const searchQuery = ref('')
const searchResults = ref(null)
const selectedPack = ref(null)

// 搜索节点
const handleSearch = async () => {
  if (!searchQuery.value.trim()) return

  searchResults.value = await service.search({
    search: searchQuery.value,
    limit: 20,
    offset: 0
  })

  if (!searchResults.value) {
    console.error('搜索失败:', service.error.value)
  }
}

// 获取包详情
const getPackDetail = async (packId: string) => {
  selectedPack.value = await service.listAllPacks({
    // 过滤参数
  })
}
</script>

<template>
  <div class="search-container">
    <input 
      v-model="searchQuery"
      @keyup.enter="handleSearch"
      placeholder="搜索节点..."
    />
    <button @click="handleSearch" :disabled="service.isLoading.value">
      {{ service.isLoading.value ? '搜索中...' : '搜索' }}
    </button>

    <div v-if="service.error.value" class="error">
      {{ service.error.value }}
    </div>

    <div v-if="searchResults" class="results">
      <div 
        v-for="pack in searchResults.items"
        :key="pack.id"
        class="pack-card"
      >
        <h3>{{ pack.name }}</h3>
        <p>{{ pack.description }}</p>
        <p>发布者: {{ pack.publisher.name }}</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.search-container {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.pack-card {
  border: 1px solid #ddd;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 0.5rem;
}

.error {
  color: red;
  padding: 1rem;
  background: #ffe0e0;
  border-radius: 4px;
}
</style>
```

---

### 示例 2: 获取特定发布者的包

```typescript
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useComfyRegistryService } from '@/services/comfyRegistryService'

const props = defineProps<{
  publisherId: string
}>()

const service = useComfyRegistryService()
const publisherInfo = ref(null)
const publisherPacks = ref(null)

onMounted(async () => {
  // 获取发布者信息
  publisherInfo.value = await service.getPublisherById(props.publisherId)

  // 获取发布者的所有包
  publisherPacks.value = await service.listPacksForPublisher(
    props.publisherId,
    false  // 不包括被禁止的包
  )
})
</script>

<template>
  <div v-if="publisherInfo" class="publisher-profile">
    <div class="header">
      <img :src="publisherInfo.avatar_url" :alt="publisherInfo.name" />
      <div>
        <h1>{{ publisherInfo.name }}</h1>
        <p>{{ publisherInfo.description }}</p>
      </div>
    </div>

    <div class="packages">
      <h2>包 ({{ publisherPacks?.length || 0 }})</h2>
      <div v-if="publisherPacks?.length" class="package-grid">
        <div 
          v-for="pack in publisherPacks"
          :key="pack.id"
          class="package-card"
        >
          <h3>{{ pack.name }}</h3>
          <p class="version">v{{ pack.latest_version }}</p>
          <p class="description">{{ pack.description }}</p>
        </div>
      </div>
      <p v-else>此发布者没有包</p>
    </div>
  </div>

  <div v-if="service.error.value" class="error">
    加载失败: {{ service.error.value }}
  </div>
</template>

<style scoped>
.publisher-profile {
  max-width: 1200px;
}

.header {
  display: flex;
  gap: 2rem;
  margin-bottom: 2rem;
}

.header img {
  width: 150px;
  height: 150px;
  border-radius: 50%;
}

.package-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 1rem;
}

.package-card {
  border: 1px solid #ddd;
  padding: 1rem;
  border-radius: 8px;
}

.version {
  color: #666;
  font-size: 0.9em;
}
</style>
```

---

### 示例 3: 添加包评论

```typescript
<script setup lang="ts">
import { ref } from 'vue'
import { useComfyRegistryService } from '@/services/comfyRegistryService'

const props = defineProps<{
  packId: string
}>()

const service = useComfyRegistryService()
const rating = ref(5)
const isSubmitting = ref(false)

const submitReview = async () => {
  isSubmitting.value = true
  try {
    await service.postPackReview(props.packId, rating.value)
    console.log('评论已提交')
    rating.value = 5  // 重置表单
  } catch (error) {
    console.error('提交评论失败:', error)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <div class="review-form">
    <h3>提交评论</h3>
    
    <div class="rating">
      <label>评分:</label>
      <select v-model.number="rating">
        <option :value="1">1 - 很差</option>
        <option :value="2">2 - 差</option>
        <option :value="3">3 - 一般</option>
        <option :value="4">4 - 好</option>
        <option :value="5">5 - 很好</option>
      </select>
    </div>

    <button 
      @click="submitReview"
      :disabled="isSubmitting || service.isLoading.value"
    >
      {{ isSubmitting ? '提交中...' : '提交评论' }}
    </button>

    <p v-if="service.error.value" class="error">
      {{ service.error.value }}
    </p>
  </div>
</template>

<style scoped>
.review-form {
  padding: 1rem;
  border: 1px solid #ddd;
  border-radius: 8px;
}

.rating {
  margin: 1rem 0;
  display: flex;
  gap: 1rem;
  align-items: center;
}

select {
  flex: 1;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
}

button {
  padding: 0.75rem 1.5rem;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.error {
  color: red;
  margin-top: 1rem;
}
</style>
```

---

## 客户事件 API 示例

### 示例 1: 显示用户事件列表

```typescript
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useCustomerEventsService } from '@/services/customerEventsService'

const service = useCustomerEventsService()
const events = ref(null)

onMounted(async () => {
  events.value = await service.getMyEvents()
})
</script>

<template>
  <div class="events-container">
    <h2>我的事件</h2>

    <div v-if="service.isLoading.value" class="loading">
      加载中...
    </div>

    <div v-else-if="events">
      <div v-if="events.events.length" class="events-list">
        <div 
          v-for="event in events.events"
          :key="event.event_id"
          class="event-item"
          :class="{ [getEventSeverity(event.event_type)]: true }"
        >
          <div class="event-type">
            {{ service.formatEventType(event.event_type) }}
          </div>
          <div class="event-date">
            {{ service.formatDate(event.createdAt) }}
          </div>
          <div class="event-details">
            <pre>{{ JSON.stringify(event.params, null, 2) }}</pre>
          </div>
        </div>
      </div>
      <p v-else>没有事件</p>

      <div class="pagination">
        <p>
          第 {{ events.page }} 页，共 {{ events.totalPages }} 页
          (总计: {{ events.total }} 条)
        </p>
      </div>
    </div>

    <div v-if="service.error.value" class="error">
      {{ service.error.value }}
    </div>
  </div>
</template>

<script setup lang="ts">
const getEventSeverity = (eventType: string) => {
  switch (eventType) {
    case 'credit_added':
      return 'success'
    case 'api_usage_completed':
      return 'info'
    default:
      return 'neutral'
  }
}
</script>

<style scoped>
.events-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.event-item {
  border-left: 4px solid #ddd;
  padding: 1rem;
  background: #f9f9f9;
  border-radius: 4px;
}

.event-item.success {
  border-left-color: #28a745;
  background: #f0f8f4;
}

.event-item.info {
  border-left-color: #17a2b8;
  background: #f0f7f9;
}

.event-type {
  font-weight: bold;
  font-size: 1.1em;
  margin-bottom: 0.5rem;
}

.event-date {
  color: #666;
  font-size: 0.9em;
  margin-bottom: 0.5rem;
}

.event-details pre {
  background: white;
  padding: 0.5rem;
  border-radius: 4px;
  overflow-x: auto;
  font-size: 0.85em;
}

.pagination {
  margin-top: 1rem;
  text-align: center;
  color: #666;
}

.error {
  color: red;
  padding: 1rem;
  background: #ffe0e0;
  border-radius: 4px;
  margin-top: 1rem;
}
</style>
```

---

## 工作区 API 示例

### 示例 1: 工作区管理面板

```typescript
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { workspaceApi } from '@/platform/workspace/api/workspaceApi'

const workspaces = ref([])
const selectedWorkspace = ref(null)
const showCreateForm = ref(false)
const newWorkspaceName = ref('')

onMounted(async () => {
  try {
    const response = await workspaceApi.list()
    workspaces.value = response.workspaces
  } catch (error) {
    console.error('加载工作区失败:', error)
  }
})

const createWorkspace = async () => {
  if (!newWorkspaceName.value.trim()) return

  try {
    const workspace = await workspaceApi.create({
      name: newWorkspaceName.value
    })
    workspaces.value.push(workspace)
    newWorkspaceName.value = ''
    showCreateForm.value = false
  } catch (error) {
    console.error('创建工作区失败:', error)
  }
}

const selectWorkspace = (workspace) => {
  selectedWorkspace.value = workspace
}

const deleteWorkspace = async (workspaceId: string) => {
  if (!confirm('确定要删除此工作区吗?')) return

  try {
    await workspaceApi.delete(workspaceId)
    workspaces.value = workspaces.value.filter(w => w.id !== workspaceId)
    selectedWorkspace.value = null
  } catch (error) {
    console.error('删除工作区失败:', error)
  }
}
</script>

<template>
  <div class="workspace-manager">
    <div class="sidebar">
      <h2>工作区</h2>
      <button @click="showCreateForm = !showCreateForm" class="btn-primary">
        {{ showCreateForm ? '取消' : '新建工作区' }}
      </button>

      <div v-if="showCreateForm" class="create-form">
        <input 
          v-model="newWorkspaceName"
          placeholder="工作区名称"
          @keyup.enter="createWorkspace"
        />
        <button @click="createWorkspace" class="btn-primary">创建</button>
      </div>

      <div class="workspace-list">
        <div 
          v-for="ws in workspaces"
          :key="ws.id"
          class="workspace-item"
          :class="{ active: selectedWorkspace?.id === ws.id }"
          @click="selectWorkspace(ws)"
        >
          <div class="name">{{ ws.name }}</div>
          <div class="role">{{ ws.role }}</div>
        </div>
      </div>
    </div>

    <div v-if="selectedWorkspace" class="main-content">
      <h2>{{ selectedWorkspace.name }}</h2>
      
      <div class="tabs">
        <WorkspaceMembers :workspace-id="selectedWorkspace.id" />
        <WorkspaceInvites :workspace-id="selectedWorkspace.id" />
      </div>

      <div class="danger-zone">
        <h3>危险区域</h3>
        <button 
          @click="deleteWorkspace(selectedWorkspace.id)"
          class="btn-danger"
        >
          删除工作区
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.workspace-manager {
  display: grid;
  grid-template-columns: 250px 1fr;
  gap: 2rem;
  height: 100vh;
}

.sidebar {
  border-right: 1px solid #ddd;
  padding: 1rem;
  overflow-y: auto;
}

.workspace-list {
  margin-top: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.workspace-item {
  padding: 0.75rem;
  border-radius: 4px;
  cursor: pointer;
  background: #f5f5f5;
}

.workspace-item.active {
  background: #007bff;
  color: white;
}

.main-content {
  padding: 2rem;
}

.danger-zone {
  margin-top: 2rem;
  padding: 1rem;
  border: 1px solid #ff6b6b;
  border-radius: 4px;
  background: #fff5f5;
}

.btn-primary {
  padding: 0.75rem 1rem;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  width: 100%;
}

.btn-danger {
  padding: 0.75rem 1rem;
  background: #dc3545;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
</style>
```

---

### 示例 2: 邀请成员

```typescript
<script setup lang="ts">
import { ref } from 'vue'
import { workspaceApi } from '@/platform/workspace/api/workspaceApi'

const props = defineProps<{
  workspaceId: string
}>()

const email = ref('')
const role = ref('member')
const isSubmitting = ref(false)

const inviteUser = async () => {
  if (!email.value.trim()) return

  isSubmitting.value = true
  try {
    const invite = await workspaceApi.createInvite({
      email: email.value,
      role: role.value
    })
    console.log('邀请已发送:', invite)
    email.value = ''
    role.value = 'member'
  } catch (error) {
    console.error('邀请失败:', error)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <div class="invite-form">
    <h3>邀请成员</h3>
    
    <div class="form-group">
      <label>邮箱地址:</label>
      <input 
        v-model="email"
        type="email"
        placeholder="user@example.com"
      />
    </div>

    <div class="form-group">
      <label>角色:</label>
      <select v-model="role">
        <option value="member">成员</option>
        <option value="admin">管理员</option>
      </select>
    </div>

    <button 
      @click="inviteUser"
      :disabled="isSubmitting || !email.trim()"
    >
      {{ isSubmitting ? '发送中...' : '发送邀请' }}
    </button>
  </div>
</template>

<style scoped>
.invite-form {
  padding: 1rem;
  border: 1px solid #ddd;
  border-radius: 8px;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
}

button {
  padding: 0.75rem 1.5rem;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  width: 100%;
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
```

---

## 后端 API 示例

### 示例 1: 获取系统信息

```typescript
import { api } from '@/scripts/api'

// 获取节点定义
async function loadNodeDefinitions() {
  try {
    const response = await api.fetchApi('/nodes')
    const nodeDefs = await response.json()
    console.log('节点定义:', nodeDefs)
    return nodeDefs
  } catch (error) {
    console.error('加载节点定义失败:', error)
  }
}

// 获取系统配置
async function loadSystemConfig() {
  try {
    const response = await api.fetchApi('/config')
    const config = await response.json()
    console.log('系统配置:', config)
    return config
  } catch (error) {
    console.error('加载配置失败:', error)
  }
}

// 获取模型列表
async function loadModels() {
  try {
    const checkpoints = await api.fetchApi('/models/checkpoints')
    const loras = await api.fetchApi('/models/loras')
    const embeddings = await api.fetchApi('/embeddings')

    return {
      checkpoints: await checkpoints.json(),
      loras: await loras.json(),
      embeddings: await embeddings.json()
    }
  } catch (error) {
    console.error('加载模型失败:', error)
  }
}
```

---

### 示例 2: 提交工作流执行

```typescript
<script setup lang="ts">
import { ref } from 'vue'
import { api } from '@/scripts/api'

const workflow = ref({
  // 示例工作流
  '1': {
    inputs: {
      text: 'a beautiful landscape'
    },
    class_type: 'CLIPTextEncode'
  },
  '2': {
    inputs: {
      seed: 12345,
      steps: 20,
      cfg: 7.5,
      sampler_name: 'euler',
      scheduler: 'normal',
      denoise: 1.0,
      model: ['3', 0],
      positive: ['1', 0],
      negative: ['4', 0],
      latent_image: ['5', 0]
    },
    class_type: 'KSampler'
  }
})

const executionId = ref(null)
const isExecuting = ref(false)

const executeWorkflow = async () => {
  isExecuting.value = true
  try {
    // 提交工作流到队列
    const response = await api.queuePrompt(workflow.value)
    executionId.value = response.prompt_id
    console.log('工作流已队列:', response)
  } catch (error) {
    console.error('执行失败:', error)
  } finally {
    isExecuting.value = false
  }
}

// 监听执行完成
api.addEventListener('execution_success', (event) => {
  if (event.detail.prompt_id === executionId.value) {
    console.log('执行成功:', event.detail.outputs)
  }
})

// 监听执行错误
api.addEventListener('execution_error', (event) => {
  if (event.detail.prompt_id === executionId.value) {
    console.error('执行错误:', event.detail.exception_message)
  }
})
</script>

<template>
  <div class="executor">
    <button 
      @click="executeWorkflow"
      :disabled="isExecuting"
    >
      {{ isExecuting ? '执行中...' : '执行工作流' }}
    </button>

    <div v-if="executionId" class="status">
      <p>执行 ID: {{ executionId }}</p>
    </div>
  </div>
</template>
```

---

## WebSocket 示例

### 示例 1: 监听执行进度

```typescript
<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { api } from '@/scripts/api'

const progress = ref(0)
const currentNode = ref(null)
const executionStatus = ref('idle')

onMounted(() => {
  // 监听执行开始
  api.addEventListener('execution_start', (event) => {
    executionStatus.value = 'running'
    progress.value = 0
    console.log('执行开始:', event.detail.prompt_id)
  })

  // 监听执行中
  api.addEventListener('executing', (event) => {
    currentNode.value = event.detail.node
    console.log('执行节点:', event.detail.node)
  })

  // 监听进度
  api.addEventListener('progress', (event) => {
    const { value, max } = event.detail
    progress.value = (value / max) * 100
  })

  // 监听执行成功
  api.addEventListener('execution_success', (event) => {
    executionStatus.value = 'success'
    progress.value = 100
    console.log('执行成功:', event.detail.outputs)
  })

  // 监听执行错误
  api.addEventListener('execution_error', (event) => {
    executionStatus.value = 'error'
    console.error('错误:', event.detail.exception_message)
  })

  // 监听中断
  api.addEventListener('execution_interrupted', (event) => {
    executionStatus.value = 'interrupted'
  })
})

onUnmounted(() => {
  // 清理监听器（可选）
})
</script>

<template>
  <div class="progress-monitor">
    <div class="status-bar">
      <div 
        class="progress-fill"
        :style="{ width: progress + '%' }"
      ></div>
    </div>
    
    <p class="progress-text">{{ progress.toFixed(0) }}%</p>

    <div class="status">
      <p>状态: {{ executionStatus }}</p>
      <p v-if="currentNode">当前节点: {{ currentNode }}</p>
    </div>
  </div>
</template>

<style scoped>
.progress-monitor {
  padding: 2rem;
}

.status-bar {
  width: 100%;
  height: 20px;
  background: #f0f0f0;
  border-radius: 10px;
  overflow: hidden;
  margin-bottom: 1rem;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #007bff, #0056b3);
  transition: width 0.3s ease;
}

.progress-text {
  text-align: center;
  font-size: 1.2em;
  font-weight: bold;
  color: #333;
}

.status {
  margin-top: 1rem;
  padding: 1rem;
  background: #f9f9f9;
  border-radius: 4px;
}
</style>
```

---

### 示例 2: 实时日志查看

```typescript
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { api } from '@/scripts/api'

const logs = ref<string[]>([])
const logsContainer = ref(null)

onMounted(() => {
  // 监听日志消息
  api.addEventListener('logs', (event) => {
    const { messages } = event.detail
    messages.forEach((msg) => {
      logs.value.push(msg)
    })
    
    // 自动滚动到底部
    if (logsContainer.value) {
      setTimeout(() => {
        logsContainer.value.scrollTop = logsContainer.value.scrollHeight
      }, 0)
    }
  })
})

const clearLogs = () => {
  logs.value = []
}
</script>

<template>
  <div class="log-viewer">
    <div class="toolbar">
      <h3>执行日志</h3>
      <button @click="clearLogs">清空</button>
    </div>
    
    <div ref="logsContainer" class="logs-container">
      <div v-if="!logs.length" class="empty">
        暂无日志
      </div>
      <div v-for="(log, index) in logs" :key="index" class="log-line">
        {{ log }}
      </div>
    </div>
  </div>
</template>

<style scoped>
.log-viewer {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid #ddd;
}

.logs-container {
  flex: 1;
  overflow-y: auto;
  padding: 1rem;
  background: #1e1e1e;
  color: #00ff00;
  font-family: 'Courier New', monospace;
  font-size: 0.9em;
}

.empty {
  text-align: center;
  color: #666;
  padding: 2rem;
}

.log-line {
  padding: 0.25rem 0;
  white-space: pre-wrap;
  word-break: break-word;
}

button {
  padding: 0.5rem 1rem;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
</style>
```

---

## 错误处理

### 示例: 完整的错误处理

```typescript
<script setup lang="ts">
import { ref } from 'vue'
import { useComfyRegistryService } from '@/services/comfyRegistryService'

const service = useComfyRegistryService()
const data = ref(null)
const errorDetails = ref(null)

const loadData = async () => {
  data.value = null
  errorDetails.value = null

  try {
    data.value = await service.search({ search: 'term' })
    
    if (!data.value) {
      // API 返回 null（有错误）
      errorDetails.value = {
        type: 'api_error',
        message: service.error.value,
        timestamp: new Date()
      }
    }
  } catch (error) {
    // 意外错误
    errorDetails.value = {
      type: 'unexpected_error',
      message: error instanceof Error ? error.message : String(error),
      timestamp: new Date()
    }
  }
}
</script>

<template>
  <div class="error-handler">
    <button @click="loadData">加载数据</button>

    <div v-if="service.isLoading.value" class="loading">
      加载中...
    </div>

    <div v-else-if="data" class="success">
      数据已加载: {{ data.length }} 项
    </div>

    <div v-else-if="errorDetails" class="error-display">
      <h3>错误详情</h3>
      <p><strong>类型:</strong> {{ errorDetails.type }}</p>
      <p><strong>消息:</strong> {{ errorDetails.message }}</p>
      <p><strong>时间:</strong> {{ errorDetails.timestamp.toLocaleString() }}</p>

      <div class="retry">
        <button @click="loadData">重试</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.error-display {
  padding: 1rem;
  background: #fff3cd;
  border: 1px solid #ffc107;
  border-radius: 4px;
  margin-top: 1rem;
}

.success {
  padding: 1rem;
  background: #d4edda;
  border: 1px solid #28a745;
  border-radius: 4px;
  margin-top: 1rem;
}

.loading {
  padding: 1rem;
  text-align: center;
  color: #666;
}

.retry {
  margin-top: 1rem;
}

button {
  padding: 0.75rem 1rem;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
</style>
```

---

## 相关文件

- [完整 API 文档](./API_DOCUMENTATION.md)
- [API 快速参考](./API_QUICK_REFERENCE.md)
- [Comfy Registry Service](../src/services/comfyRegistryService.ts)
- [Customer Events Service](../src/services/customerEventsService.ts)
- [Workspace API](../src/platform/workspace/api/workspaceApi.ts)
- [Main API](../src/scripts/api.ts)

---

**最后更新**: 2024
**文档版本**: 1.0
