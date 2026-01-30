# ComfyUI API 快速参考

快速查阅 ComfyUI 前端和后端 API 端点的速查表。

## 前端服务 API 快速参考

### 1. Comfy Registry Service
```typescript
import { useComfyRegistryService } from '@/services/comfyRegistryService'
const service = useComfyRegistryService()
```

| 方法 | 签名 | 端点 | 用途 |
|------|------|------|------|
| `getNodeDefs` | `(packId, version, params?, signal?) => Promise<T \| null>` | `GET /nodes/{packId}/versions/{versionId}/comfy-nodes` | 获取节点定义 |
| `search` | `(params?, signal?) => Promise<SearchResponse \| null>` | `GET /nodes/search` | 搜索节点包 |
| `getPublisherById` | `(publisherId, signal?) => Promise<Publisher \| null>` | `GET /publishers/{publisherId}` | 获取发布者信息 |
| `listPacksForPublisher` | `(publisherId, includeBanned?, signal?) => Promise<Node[] \| null>` | `GET /publishers/{publisherId}/nodes` | 列出发布者的包 |
| `postPackReview` | `(packId, star, signal?) => Promise<Node \| null>` | `POST /nodes/{packId}/reviews` | 添加包评论 |
| `listAllPacks` | `(params?, signal?) => Promise<ListResponse \| null>` | `GET /nodes` | 列出所有包 |

**基础 URL**: `https://api.comfy.org`

**状态属性**:
- `isLoading: Ref<boolean>`
- `error: Ref<string \| null>`

---

### 2. Customer Events Service
```typescript
import { useCustomerEventsService } from '@/services/customerEventsService'
const service = useCustomerEventsService()
```

| 方法 | 签名 | 端点 | 用途 |
|------|------|------|------|
| `getMyEvents` | `(params?, signal?) => Promise<EventResponse \| null>` | `GET /customer/events` | 获取用户事件 |
| `formatEventType` | `(eventType: string) => string` | - | 格式化事件类型文本 |
| `formatDate` | `(dateString: string) => string` | - | 格式化日期 |

**事件类型**:
```typescript
enum EventType {
  CREDIT_ADDED = 'credit_added',
  ACCOUNT_CREATED = 'account_created',
  API_USAGE_STARTED = 'api_usage_started',
  API_USAGE_COMPLETED = 'api_usage_completed'
}
```

**需要认证**: ✓ Authorization 头

---

### 3. Release Service
```typescript
import { useReleaseService } from '@/platform/updates/common/releaseService'
const service = useReleaseService()
```

| 方法 | 签名 | 端点 | 用途 |
|------|------|------|------|
| `getReleases` | `(params, signal?) => Promise<ReleaseNote[] \| null>` | `GET /releases` | 获取发布版本 |

**参数示例**:
```typescript
{
  project: 'comfyui',
  current_version: '1.0.0',
  form_factor?: 'desktop'
}
```

---

### 4. Workspace API
```typescript
import { workspaceApi } from '@/platform/workspace/api/workspaceApi'
```

| 方法 | 签名 | 端点 | 用途 |
|------|------|------|------|
| `list` | `() => Promise<ListWorkspacesResponse>` | `GET /api/workspaces` | 列出工作区 |
| `create` | `(payload) => Promise<WorkspaceWithRole>` | `POST /api/workspaces` | 创建工作区 |
| `update` | `(id, payload) => Promise<WorkspaceWithRole>` | `PATCH /api/workspaces/{id}` | 更新工作区 |
| `delete` | `(id) => Promise<void>` | `DELETE /api/workspaces/{id}` | 删除工作区 |
| `leave` | `() => Promise<void>` | `POST /api/workspace/leave` | 离开工作区 |
| `listMembers` | `(params?) => Promise<ListMembersResponse>` | `GET /api/workspace/members` | 列出成员 |
| `removeMember` | `(userId) => Promise<void>` | `DELETE /api/workspace/members/{userId}` | 移除成员 |
| `listInvites` | `() => Promise<ListInvitesResponse>` | `GET /api/workspace/invites` | 列出邀请 |
| `createInvite` | `(payload) => Promise<PendingInvite>` | `POST /api/workspace/invites` | 创建邀请 |
| `revokeInvite` | `(inviteId) => Promise<void>` | `DELETE /api/workspace/invites/{inviteId}` | 撤销邀请 |
| `acceptInvite` | `(token) => Promise<AcceptInviteResponse>` | `POST /api/invites/{token}/accept` | 接受邀请 |
| `accessBillingPortal` | `(returnUrl?) => Promise<BillingPortalResponse>` | `POST /api/billing/portal` | 访问账单 |

**需要认证**: ✓ Authorization 头

---

## 后端 REST API 快速参考

### 状态和配置
| 端点 | 方法 | 用途 |
|------|------|------|
| `/api/prompt` | `GET` | 获取系统状态 |
| `/api/config` | `GET` | 获取系统配置 |
| `/api/info` | `GET` | 获取节点信息 |
| `/api/nodes` | `GET` | 获取所有节点定义 |

### 队列管理
| 端点 | 方法 | 用途 |
|------|------|------|
| `/api/prompt` | `POST` | 提交工作流到队列 |
| `/api/queue` | `GET` | 获取队列状态 |
| `/api/queue` | `POST` | 清空队列 |
| `/api/history` | `GET` | 获取执行历史 |

### 模型和资源
| 端点 | 方法 | 用途 |
|------|------|------|
| `/api/models/checkpoints` | `GET` | 获取检查点列表 |
| `/api/models/loras` | `GET` | 获取 LoRA 列表 |
| `/api/embeddings` | `GET` | 获取嵌入列表 |

### 设置和用户
| 端点 | 方法 | 用途 |
|------|------|------|
| `/api/settings` | `GET` | 获取用户设置 |
| `/api/settings` | `POST` | 更新用户设置 |
| `/api/users` | `GET` | 获取用户列表 |

### 资源删除
| 端点 | 方法 | 用途 |
|------|------|------|
| `/api/delete/{id}` | `DELETE` | 删除执行历史 |

### 功能和媒体
| 端点 | 方法 | 用途 |
|------|------|------|
| `/api/features` | `GET` | 获取功能标志 |
| `/api/view` | `GET` | 获取图像视图 |
| `/api/viewvideo` | `GET` | 获取视频视图 |

---

## WebSocket 消息类型

### 系统消息
| 类型 | 数据 | 用途 |
|------|------|------|
| `status` | `StatusWsMessageStatus` | 系统状态更新 |
| `feature_flags` | `Record<string, unknown>` | 功能标志 |
| `notification` | `{ title, message, severity }` | 通知 |

### 执行消息
| 类型 | 数据 | 用途 |
|------|------|------|
| `execution_start` | `{ prompt_id }` | 开始执行 |
| `executing` | `{ node, prompt_id }` | 执行节点 |
| `execution_success` | `{ prompt_id, outputs }` | 执行成功 |
| `execution_error` | `{ prompt_id, node_id, exception_message, traceback }` | 执行错误 |
| `execution_interrupted` | `{ prompt_id }` | 执行中断 |
| `execution_cached` | `{ prompt_id, outputs, nodes }` | 使用缓存 |

### 进度消息
| 类型 | 数据 | 用途 |
|------|------|------|
| `progress` | `{ value, max }` | 进度百分比 |
| `progress_text` | `{ text }` | 进度文本 |
| `progress_state` | `{ state }` | 进度状态 |

### 日志和预览
| 类型 | 数据 | 用途 |
|------|------|------|
| `logs` | `{ messages }` | 日志消息 |
| `b_preview` | `Blob` | 二进制预览 |
| `b_preview_with_metadata` | `{ blob, nodeId, promptId }` | 带元数据预览 |

### 下载
| 类型 | 数据 | 用途 |
|------|------|------|
| `asset_download` | `{ url, filename }` | 资源下载 |

---

## 常见代码模式

### 创建服务实例
```typescript
// Registry Service
const registryService = useComfyRegistryService()

// Customer Events
const eventsService = useCustomerEventsService()

// Release Service
const releaseService = useReleaseService()

// Workspace API
import { workspaceApi } from '@/platform/workspace/api/workspaceApi'
```

### 处理异步操作
```typescript
// 基本调用
const data = await service.someMethod(params)
if (data) {
  // 成功
  console.log(data)
} else {
  // 错误在 service.error.value 中
  console.error(service.error.value)
}

// 使用加载状态
watchEffect(() => {
  if (service.isLoading.value) {
    console.log('加载中...')
  }
})
```

### 取消请求
```typescript
const controller = new AbortController()

// 发送请求
const promise = service.search(
  { search: 'term' },
  controller.signal
)

// 在 5 秒后取消
setTimeout(() => controller.abort(), 5000)
```

### WebSocket 事件监听
```typescript
import { api } from '@/scripts/api'

// 监听执行开始
api.addEventListener('execution_start', (event) => {
  console.log('执行开始:', event.detail.prompt_id)
})

// 监听进度
api.addEventListener('progress', (event) => {
  const { value, max } = event.detail
  const percent = (value / max) * 100
  console.log(`进度: ${percent.toFixed(0)}%`)
})

// 监听错误
api.addEventListener('execution_error', (event) => {
  const { exception_message, traceback } = event.detail
  console.error('错误:', exception_message)
  console.error('堆栈:', traceback.join('\n'))
})
```

### 提交工作流
```typescript
import { api } from '@/scripts/api'

const workflow = {
  // 节点定义...
}

try {
  const response = await api.queuePrompt(workflow)
  console.log('队列 ID:', response.prompt_id)
  console.log('队列号:', response.number)
} catch (error) {
  if (error instanceof api.UnauthorizedError) {
    console.error('未授权')
  } else {
    console.error('队列失败:', error)
  }
}
```

### 管理工作区
```typescript
// 获取所有工作区
try {
  const { workspaces } = await workspaceApi.list()
  console.log('工作区:', workspaces)
} catch (error) {
  console.error('获取工作区失败:', error)
}

// 创建工作区
try {
  const workspace = await workspaceApi.create({
    name: 'My New Workspace'
  })
  console.log('创建成功:', workspace)
} catch (error) {
  console.error('创建失败:', error)
}

// 邀请用户
try {
  const invite = await workspaceApi.createInvite({
    email: 'user@example.com',
    role: 'member'
  })
  console.log('邀请已发送:', invite)
} catch (error) {
  console.error('邀请失败:', error)
}
```

---

## 错误代码映射

| 状态码 | 含义 | 处理方式 |
|--------|------|---------|
| `400` | Bad Request | 检查请求参数 |
| `401` | Unauthorized | 检查认证凭证 |
| `403` | Forbidden | 检查权限 |
| `404` | Not Found | 检查资源 ID |
| `409` | Conflict | 资源冲突，重试 |
| `500` | Server Error | 服务器问题，重试 |

---

## 认证头

### Firebase 认证（Cloud）
```
Authorization: Bearer {jwt_token}
```

### Comfy Org 认证
```
X-API-Key: {api_key}
Authorization: Bearer {auth_token}
```

### 用户标识
```
Comfy-User: {username}
```

---

## 超时和重试

### 默认超时
- HTTP 请求: 30 秒
- WebSocket: 无超时（自动重连）

### 重试策略
- 网络错误: 自动重试（最多 3 次）
- 5xx 错误: 自动重试（指数退避）
- 4xx 错误: 无重试

---

## 请求/响应示例

### 搜索节点
```javascript
// 请求
GET https://api.comfy.org/nodes/search?search=controlnet&limit=20

// 响应
{
  "items": [
    {
      "id": "package-1",
      "name": "ControlNet",
      "description": "...",
      "publisher": {...},
      "versions": [...]
    }
  ],
  "total": 123,
  "offset": 0,
  "limit": 20
}
```

### 提交工作流
```javascript
// 请求
POST /api/prompt
Content-Type: application/json

{
  "client_id": "client-123",
  "prompt": {
    "1": {
      "inputs": {"text": "..."},
      "class_type": "CLIPTextEncode"
    }
  },
  "extra_data": {
    "extra_pnginfo": {
      "workflow": {...}
    }
  }
}

// 响应
{
  "prompt_id": "uuid-string",
  "number": 42
}
```

### WebSocket 消息
```javascript
// 执行开始
{
  "type": "execution_start",
  "data": {
    "prompt_id": "uuid-string"
  }
}

// 进度更新
{
  "type": "progress",
  "data": {
    "value": 5,
    "max": 10
  }
}

// 执行成功
{
  "type": "execution_success",
  "data": {
    "prompt_id": "uuid-string",
    "outputs": {
      "1": {
        "images": [{"filename": "image.png"}]
      }
    }
  }
}
```

---

## 相关文件

- [完整 API 文档](./API_DOCUMENTATION.md)
- [服务实现](../src/services/)
- [工作区 API](../src/platform/workspace/api/)
- [API 主脚本](../src/scripts/api.ts)

---

**最后更新**: 2024
**文档版本**: 1.0
