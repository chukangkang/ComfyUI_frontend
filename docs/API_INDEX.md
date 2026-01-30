# API 文档索引

本项目的 API 文档已生成完成。以下是文档导航和快速查找指南。

## 📚 文档清单

### 1. [API 完整文档](./API_DOCUMENTATION.md)
最全面的 API 参考文档，包含所有端点、参数和响应的详细说明。

**包含内容**:
- ✅ Comfy Registry API（节点包管理）
- ✅ 客户事件 API（用户事件追踪）
- ✅ 发布版本服务 API（版本管理）
- ✅ 工作区 API（团队协作）
- ✅ 后端 REST API（执行和队列）
- ✅ WebSocket API（实时通信）
- ✅ 错误处理指南
- ✅ 认证方式

**推荐用途**: 深入理解 API 的完整功能和细节

---

### 2. [API 快速参考](./API_QUICK_REFERENCE.md)
速查表格式的 API 参考，快速定位 API 端点和方法。

**包含内容**:
- ✅ 所有服务的方法速查表
- ✅ 端点对应表
- ✅ WebSocket 消息类型表
- ✅ 常见代码模式
- ✅ 错误代码映射
- ✅ 请求/响应示例

**推荐用途**: 快速查找 API 方法签名、端点 URL 和参数

---

### 3. [API 使用示例](./API_USAGE_EXAMPLES.md)
实际的代码示例，展示如何在项目中使用各种 API。

**包含内容**:
- ✅ Registry API 搜索示例
- ✅ 客户事件列表显示
- ✅ 工作区管理面板
- ✅ 工作流执行示例
- ✅ WebSocket 监听示例
- ✅ 进度追踪示例
- ✅ 错误处理示例

**推荐用途**: 学习如何在 Vue 3 组件中集成 API 调用

---

## 🎯 快速查找

### 我想...

#### 搜索和管理节点包
→ [Registry API](./API_DOCUMENTATION.md#comfy-registry-api)
```typescript
import { useComfyRegistryService } from '@/services/comfyRegistryService'
const service = useComfyRegistryService()
const results = await service.search({ search: 'term' })
```

#### 获取用户事件信息
→ [Customer Events API](./API_DOCUMENTATION.md#客户事件-api)
```typescript
import { useCustomerEventsService } from '@/services/customerEventsService'
const service = useCustomerEventsService()
const events = await service.getMyEvents()
```

#### 检查新版本发布
→ [Release Service](./API_DOCUMENTATION.md#发布版本服务-api)
```typescript
import { useReleaseService } from '@/platform/updates/common/releaseService'
const service = useReleaseService()
const releases = await service.getReleases({ project: 'comfyui', current_version: '1.0.0' })
```

#### 管理工作区和成员
→ [Workspace API](./API_DOCUMENTATION.md#工作区-api)
```typescript
import { workspaceApi } from '@/platform/workspace/api/workspaceApi'
const workspaces = await workspaceApi.list()
```

#### 提交工作流执行
→ [后端 API](./API_DOCUMENTATION.md#后端-rest-api)
```typescript
import { api } from '@/scripts/api'
const response = await api.queuePrompt(workflow)
```

#### 实时监听执行进度
→ [WebSocket API](./API_DOCUMENTATION.md#websocket-api)
```typescript
api.addEventListener('progress', (event) => {
  console.log(`进度: ${event.detail.value}/${event.detail.max}`)
})
```

---

## 📖 按用途分类

### 前端服务（Frontend Services）

| 服务 | 用途 | 文档 |
|------|------|------|
| Registry Service | 节点包管理和搜索 | [Registry API](./API_DOCUMENTATION.md#comfy-registry-api) |
| Customer Events | 用户事件追踪 | [Events API](./API_DOCUMENTATION.md#客户事件-api) |
| Release Service | 版本和更新管理 | [Release API](./API_DOCUMENTATION.md#发布版本服务-api) |
| Workspace API | 团队协作和权限 | [Workspace API](./API_DOCUMENTATION.md#工作区-api) |

### 后端接口（Backend APIs）

| 分类 | 端点 | 用途 | 文档 |
|------|------|------|------|
| 状态 | `/api/prompt`, `/api/info` | 获取系统状态 | [后端 API](./API_DOCUMENTATION.md#后端-rest-api) |
| 队列 | `/api/queue`, `/api/prompt` | 管理执行队列 | [后端 API](./API_DOCUMENTATION.md#后端-rest-api) |
| 模型 | `/api/models/*` | 获取模型列表 | [后端 API](./API_DOCUMENTATION.md#后端-rest-api) |
| 设置 | `/api/settings` | 管理用户设置 | [后端 API](./API_DOCUMENTATION.md#后端-rest-api) |
| 实时 | `/ws` | WebSocket 连接 | [WebSocket API](./API_DOCUMENTATION.md#websocket-api) |

---

## 🔐 认证

### 认证类型

1. **Firebase 认证** (Cloud 部署)
   ```
   Authorization: Bearer {jwt_token}
   ```

2. **API 密钥**
   ```
   X-API-Key: {api_key}
   ```

3. **用户标识** (所有请求)
   ```
   Comfy-User: {username}
   ```

详见: [认证章节](./API_DOCUMENTATION.md#认证)

---

## ⚠️ 错误处理

### 常见错误代码

| 代码 | 含义 | 解决方案 |
|------|------|---------|
| 400 | Bad Request | 检查请求参数 |
| 401 | Unauthorized | 检查认证凭证 |
| 403 | Forbidden | 检查权限 |
| 404 | Not Found | 检查资源 ID |
| 500 | Server Error | 重试请求 |

详见: [错误处理](./API_DOCUMENTATION.md#错误处理)

---

## 💡 最佳实践

### 1. 使用 AbortSignal 取消请求
```typescript
const controller = new AbortController()
const promise = service.search({ search: 'term' }, controller.signal)
// 取消
controller.abort()
```

### 2. 检查加载状态
```typescript
if (service.isLoading.value) {
  // 显示加载指示器
}
```

### 3. 处理错误
```typescript
const data = await service.someMethod()
if (!data) {
  console.error('错误:', service.error.value)
}
```

### 4. 监听 WebSocket 事件
```typescript
api.addEventListener('execution_success', (event) => {
  console.log('成功:', event.detail)
})
```

详见: [使用示例](./API_USAGE_EXAMPLES.md)

---

## 🔄 整合模式

### 响应式数据获取
```typescript
const service = useComfyRegistryService()
const items = ref(null)

onMounted(async () => {
  items.value = await service.search({ search: 'term' })
})

watch(service.error, (error) => {
  if (error) console.error(error)
})
```

### 进度追踪
```typescript
const progress = ref(0)

api.addEventListener('progress', (event) => {
  progress.value = (event.detail.value / event.detail.max) * 100
})
```

### 错误恢复
```typescript
const handleError = async () => {
  console.error('操作失败:', service.error.value)
  // 重试或显示用户友好的错误消息
}
```

---

## 📝 服务位置

### 前端服务代码位置
- Registry Service: `src/services/comfyRegistryService.ts`
- Events Service: `src/services/customerEventsService.ts`
- Release Service: `src/platform/updates/common/releaseService.ts`
- Workspace API: `src/platform/workspace/api/workspaceApi.ts`
- Main API: `src/scripts/api.ts`

### 配置和类型
- API 基础 URL: `src/config/comfyApi.ts`
- 类型定义: `src/types/comfyRegistryTypes.ts`
- Schema: `src/schemas/apiSchema.ts`

---

## 🚀 快速开始

### 第一次使用 API？

1. 📖 阅读 [API 快速参考](./API_QUICK_REFERENCE.md)，了解可用的 API
2. 💻 查看 [API 使用示例](./API_USAGE_EXAMPLES.md)，学习代码模式
3. 📚 参考 [完整文档](./API_DOCUMENTATION.md)，深入理解细节

### 快速集成现有 API？

1. 🔍 在 [快速参考](./API_QUICK_REFERENCE.md) 中找到你需要的方法
2. 📋 复制相应的使用示例
3. ✏️ 根据项目需求进行调整

### 遇到问题？

1. 🔎 检查 [错误处理](./API_DOCUMENTATION.md#错误处理) 章节
2. 💭 搜索相关的 [使用示例](./API_USAGE_EXAMPLES.md)
3. 📞 查阅服务的源代码注释

---

## 📞 支持和贡献

- 如发现文档错误，请提交 Issue
- 如需添加新的 API 文档，请提交 PR
- 如有建议，欢迎讨论

---

## 🗂️ 文档维护

**最后更新**: 2024
**文档版本**: 1.0

### 覆盖的 API 版本
- Comfy Registry API: 最新版本
- Workspace API: 最新版本
- Backend REST API: 兼容多个 ComfyUI 版本
- WebSocket API: 实时协议

### 已覆盖的主题
- ✅ 所有公开 API 端点
- ✅ 服务初始化和配置
- ✅ 请求和响应格式
- ✅ 错误处理和重试
- ✅ 认证和授权
- ✅ WebSocket 连接
- ✅ 常见用例和模式
- ✅ Vue 3 集成示例

---

## 📚 相关资源

- [Comfy 官方文档](https://docs.comfy.org)
- [项目 README](../README.md)
- [贡献指南](../CONTRIBUTING.md)
- [架构文档](./AGENTS.md)

---

**祝你编码愉快！** 🎉
