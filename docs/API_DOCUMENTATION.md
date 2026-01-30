# ComfyUI 前端 API 文档

完整的 ComfyUI 前端 API 调用文档，包括注册表 API、客户事件 API、后端 REST 端点和 WebSocket 连接。

## 目录

1. [Comfy Registry API](#comfy-registry-api)
2. [客户事件 API](#客户事件-api)
3. [发布版本服务 API](#发布版本服务-api)
4. [工作区 API](#工作区-api)
5. [后端 REST API](#后端-rest-api)
6. [WebSocket API](#websocket-api)
7. [错误处理](#错误处理)
8. [认证](#认证)

---

## Comfy Registry API

**基础 URL**: `https://api.comfy.org`

**客户端**: axios，位于 [src/services/comfyRegistryService.ts](../src/services/comfyRegistryService.ts)

### 获取节点定义 (getNodeDefs)

获取特定节点包版本中的 ComfyUI 节点定义。

```typescript
const getNodeDefs = async (params: {
  packId: string
  version: string
  // 其他查询参数
}, signal?: AbortSignal) => T | null
```

**参数**:
- `packId` (string) - 节点包的 ID
- `version` (string) - 节点包的版本
- `queryParams` - 查询参数（从 OpenAPI 定义继承）
- `signal` (AbortSignal, 可选) - 用于取消请求的信号

**端点**: `GET /nodes/{packId}/versions/{versionId}/comfy-nodes`

**响应**: 节点定义对象或 null（出错时）

**错误处理**:
- `403`: 该包已被禁止，其定义不可用
- `404`: 请求的节点、版本或 comfy 节点不存在

**示例**:
```typescript
const service = useComfyRegistryService()
const nodeDefs = await service.getNodeDefs({
  packId: 'my-pack',
  version: '1.0.0'
})
```

---

### 搜索节点包 (search)

获取与特定条件匹配的节点包的分页列表。支持按包名称或单个节点搜索。

```typescript
const search = async (
  params?: SearchNodesParams,
  signal?: AbortSignal
) => SearchResponse | null
```

**参数**:
- `params` (可选) - 查询参数：
  - `search` - 搜索包名称
  - `comfy_node_search` - 搜索单个节点
  - `limit` - 结果数量限制
  - `offset` - 分页偏移
- `signal` (AbortSignal, 可选) - 用于取消请求的信号

**端点**: `GET /nodes/search`

**响应**: 搜索结果数组或 null（出错时）

**错误处理**:
- 通用错误：返回 null 并设置 `error.value`

**示例**:
```typescript
const results = await service.search({
  search: 'controlnet',
  limit: 20,
  offset: 0
})
```

---

### 获取发布者信息 (getPublisherById)

获取发布者的详细信息。

```typescript
const getPublisherById = async (
  publisherId: string,
  signal?: AbortSignal
) => Publisher | null
```

**参数**:
- `publisherId` (string) - 发布者的 ID
- `signal` (AbortSignal, 可选) - 用于取消请求的信号

**端点**: `GET /publishers/{publisherId}`

**响应**: 发布者对象或 null（出错时）

**错误处理**:
- `404`: 发布者不存在

**示例**:
```typescript
const publisher = await service.getPublisherById('publisher-123')
```

---

### 列出发布者的包 (listPacksForPublisher)

列出与特定发布者关联的所有包。

```typescript
const listPacksForPublisher = async (
  publisherId: string,
  includeBanned?: boolean,
  signal?: AbortSignal
) => Node[] | null
```

**参数**:
- `publisherId` (string) - 发布者的 ID
- `includeBanned` (boolean, 可选) - 是否包含被禁止的包
- `signal` (AbortSignal, 可选) - 用于取消请求的信号

**端点**: `GET /publishers/{publisherId}/nodes`

**响应**: 节点包数组或 null（出错时）

**错误处理**:
- `400`: 无效的输入数据
- `404`: 发布者不存在

**示例**:
```typescript
const packs = await service.listPacksForPublisher('publisher-123')
```

---

### 添加包评论 (postPackReview)

为包添加或更新评论。

```typescript
const postPackReview = async (
  packId: string,
  star: number,
  signal?: AbortSignal
) => Node | null
```

**参数**:
- `packId` (string) - 包的 ID
- `star` (number) - 评分（通常 1-5）
- `signal` (AbortSignal, 可选) - 用于取消请求的信号

**端点**: `POST /nodes/{packId}/reviews?star={star}`

**请求体**: null

**响应**: 更新的节点对象或 null（出错时）

**错误处理**:
- `400`: 无效的评论
- `404`: 包不存在

**示例**:
```typescript
await service.postPackReview('pack-123', 5)
```

---

### 列出所有包 (listAllPacks)

获取注册表中所有包的分页列表。

```typescript
const listAllPacks = async (
  params?: ListAllNodesParams,
  signal?: AbortSignal
) => ListAllNodesResponse | null
```

**参数**:
- `params` (可选) - 查询参数（分页、排序等）
- `signal` (AbortSignal, 可选) - 用于取消请求的信号

**端点**: `GET /nodes`

**响应**: 包含包列表和分页信息的对象或 null（出错时）

**错误处理**:
- 通用错误：返回 null 并设置 `error.value`

**示例**:
```typescript
const packs = await service.listAllPacks({
  limit: 50,
  offset: 0
})
```

---

### Registry 服务状态

```typescript
const service = useComfyRegistryService()

// 响应式状态
service.isLoading      // boolean - 请求是否正在进行
service.error          // string | null - 错误消息（如果有）
```

---

## 客户事件 API

**基础 URL**: `getComfyApiBaseUrl()`（来自配置）

**客户端**: axios，位于 [src/services/customerEventsService.ts](../src/services/customerEventsService.ts)

### 事件类型

```typescript
enum EventType {
  CREDIT_ADDED = 'credit_added',
  ACCOUNT_CREATED = 'account_created',
  API_USAGE_STARTED = 'api_usage_started',
  API_USAGE_COMPLETED = 'api_usage_completed'
}
```

### 获取我的事件 (getMyEvents)

获取当前用户的事件列表。

```typescript
const getMyEvents = async (
  params?: GetCustomerEventsParams,
  signal?: AbortSignal
) => CustomerEventsResponse | null
```

**参数**:
- `params` (可选) - 查询参数（分页、过滤等）
- `signal` (AbortSignal, 可选) - 用于取消请求的信号

**端点**: `GET /customer/events`

**请求头**: 需要 `Authorization: Bearer {token}`

**响应**:
```typescript
{
  events: CustomerEvent[],
  total: number,
  page: number,
  limit: number,
  totalPages: number
}
```

**错误处理**:
- `401`: 缺少身份验证头
- `400`: 无效的输入（消息: "Invalid input, object invalid"）
- `404`: 未找到
- `500`: 服务器错误

**示例**:
```typescript
const service = useCustomerEventsService()
const events = await service.getMyEvents()
```

### 格式化事件类型 (formatEventType)

将事件类型字符串转换为人类可读的格式。

```typescript
const formatted = service.formatEventType(EventType.CREDIT_ADDED)
// 返回: "Credits Added"
```

### 事件服务状态

```typescript
const service = useCustomerEventsService()

service.isLoading      // boolean - 请求是否正在进行
service.error          // string | null - 错误消息（如果有）
```

---

## 发布版本服务 API

**基础 URL**: `getComfyApiBaseUrl()`

**客户端**: axios，位于 [src/platform/updates/common/releaseService.ts](../src/platform/updates/common/releaseService.ts)

### 获取发布版本 (getReleases)

从 API 获取发布版本列表。

```typescript
const getReleases = async (
  params: GetReleasesParams,
  signal?: AbortSignal
) => ReleaseNote[] | null
```

**参数**:
- `params` (必需) - 查询参数：
  - `project` (string) - 项目名称（例如：'comfyui'）
  - `current_version` (string) - 当前版本
  - `form_factor` (string, 可选) - 设备类型（例如：'desktop'）
- `signal` (AbortSignal, 可选) - 用于取消请求的信号

**端点**: `GET /releases`

**响应**:
```typescript
interface ReleaseNote {
  id: number
  project: 'comfyui'
  version: string
  attention: 'high' | 'medium' | 'low'
  content: string
  published_at: string (ISO 8601)
}
```

**错误处理**:
- `400`: 无效的项目或版本参数
- `404`: 未找到
- `500`: 服务器错误

**示例**:
```typescript
const service = useReleaseService()
const releases = await service.getReleases({
  project: 'comfyui',
  current_version: '1.0.0'
})
```

### 发布版本服务状态

```typescript
const service = useReleaseService()

service.isLoading      // boolean - 请求是否正在进行
service.error          // string | null - 错误消息（如果有）
```

---

## 工作区 API

**基础 URL**: `api.apiURL()`（带有 `/api/` 前缀）

**客户端**: axios，位于 [src/platform/workspace/api/workspaceApi.ts](../src/platform/workspace/api/workspaceApi.ts)

### 列出工作区 (list)

列出用户有权访问的所有工作区。

```typescript
const list = async (): Promise<ListWorkspacesResponse>
```

**端点**: `GET /api/workspaces`

**请求头**: 需要 `Authorization` 头

**响应**:
```typescript
{
  workspaces: WorkspaceWithRole[]
}
```

**错误**: 抛出 `WorkspaceApiError`

---

### 创建工作区 (create)

创建新工作区。

```typescript
const create = async (payload: CreateWorkspacePayload): Promise<WorkspaceWithRole>
```

**参数**:
```typescript
interface CreateWorkspacePayload {
  name: string
  // 其他工作区参数
}
```

**端点**: `POST /api/workspaces`

**请求头**: 需要 `Authorization` 头

**响应**: 新创建的工作区对象

**错误**: 抛出 `WorkspaceApiError`

---

### 更新工作区 (update)

更新工作区名称和其他属性。

```typescript
const update = async (
  workspaceId: string,
  payload: UpdateWorkspacePayload
): Promise<WorkspaceWithRole>
```

**端点**: `PATCH /api/workspaces/{id}`

**请求头**: 需要 `Authorization` 头

---

### 删除工作区 (delete)

删除工作区（仅限所有者）。

```typescript
const delete = async (workspaceId: string): Promise<void>
```

**端点**: `DELETE /api/workspaces/{id}`

**请求头**: 需要 `Authorization` 头

---

### 离开工作区 (leave)

当前用户离开工作区。

```typescript
const leave = async (): Promise<void>
```

**端点**: `POST /api/workspace/leave`

**请求头**: 需要 `Authorization` 头

---

### 列出工作区成员 (listMembers)

获取工作区成员的分页列表。

```typescript
const listMembers = async (params?: ListMembersParams): Promise<ListMembersResponse>
```

**端点**: `GET /api/workspace/members`

**请求头**: 需要 `Authorization` 头

**响应参数**:
- `limit` - 每页结果数
- `offset` - 分页偏移

---

### 移除工作区成员 (removeMember)

从工作区移除成员。

```typescript
const removeMember = async (userId: string): Promise<void>
```

**端点**: `DELETE /api/workspace/members/{userId}`

**请求头**: 需要 `Authorization` 头

---

### 列出待处理邀请 (listInvites)

列出工作区的待处理邀请。

```typescript
const listInvites = async (): Promise<ListInvitesResponse>
```

**端点**: `GET /api/workspace/invites`

**请求头**: 需要 `Authorization` 头

---

### 创建邀请 (createInvite)

为工作区创建邀请。

```typescript
const createInvite = async (payload: CreateInviteRequest): Promise<PendingInvite>
```

**参数**:
```typescript
interface CreateInviteRequest {
  email: string
  role?: string
}
```

**端点**: `POST /api/workspace/invites`

**请求头**: 需要 `Authorization` 头

---

### 撤销邀请 (revokeInvite)

撤销待处理邀请。

```typescript
const revokeInvite = async (inviteId: string): Promise<void>
```

**端点**: `DELETE /api/workspace/invites/{inviteId}`

**请求头**: 需要 `Authorization` 头

---

### 接受邀请 (acceptInvite)

接受工作区邀请（使用邀请令牌）。

```typescript
const acceptInvite = async (token: string): Promise<AcceptInviteResponse>
```

**端点**: `POST /api/invites/{token}/accept`

**请求头**: 使用 Firebase 身份验证（用户身份）

---

### 访问账单门户 (accessBillingPortal)

获取账单门户链接。

```typescript
const accessBillingPortal = async (returnUrl?: string): Promise<BillingPortalResponse>
```

**参数**:
- `returnUrl` (可选) - 返回 URL（默认：当前页面 URL）

**端点**: `POST /api/billing/portal`

**请求头**: 需要 `Authorization` 头

**请求体**:
```typescript
{
  return_url: string
}
```

---

## 后端 REST API

这些端点由 ComfyUI 后端服务提供。

### 基础端点

**基础 URL**: 由 `api.apiURL()` 或 `api.internalURL()` 提供

#### 获取状态 (GET /api/prompt)

获取当前系统状态。

```
GET /api/prompt
```

**响应**:
```typescript
interface StatusWsMessageStatus {
  status: {
    exec_info: {
      queue_pending: number
      queue_running: number
      // 其他字段
    }
  }
  sid?: string
  // 其他字段
}
```

---

#### 队列管理

**获取队列** (GET /api/queue)

```
GET /api/queue
```

**清空队列** (POST /api/queue)

```
POST /api/queue
```

---

#### 查询执行历史 (GET /api/history)

获取执行历史。

```
GET /api/history
```

---

#### 推送提示（队列工作流）(POST /api/prompt)

向后端队列提交工作流。

```typescript
interface QueuePromptRequestBody {
  client_id: string
  prompt: ComfyApiWorkflow
  partial_execution_targets?: NodeExecutionId[]
  extra_data: {
    extra_pnginfo: {
      workflow: ComfyWorkflowJSON
    }
    auth_token_comfy_org?: string
    api_key_comfy_org?: string
  }
}
```

**端点**: `POST /api/prompt`

**请求体**: `QueuePromptRequestBody`

**响应**:
```typescript
interface PromptResponse {
  prompt_id: string
  number: number
  // 其他字段
}
```

---

#### 节点信息 (GET /api/info)

获取节点和其他系统信息。

```
GET /api/info
```

---

#### 节点定义 (GET /api/nodes)

获取所有可用节点的定义。

```
GET /api/nodes
```

---

#### 配置 (GET /api/config)

获取系统配置。

```
GET /api/config
```

---

#### 模型管理

**获取检查点** (GET /api/models/checkpoints)

```
GET /api/models/checkpoints
```

**获取 LoRA** (GET /api/models/loras)

```
GET /api/models/loras
```

**获取嵌入** (GET /api/embeddings)

```
GET /api/embeddings
```

---

#### 设置

**获取用户设置** (GET /api/settings)

```
GET /api/settings
```

**更新用户设置** (POST /api/settings)

```
POST /api/settings
Content-Type: application/json

{
  "key": "value"
}
```

---

#### 用户管理

**获取用户列表** (GET /api/users)

```
GET /api/users
```

---

#### 删除资源

**删除提示** (DELETE /api/delete/{id})

```
DELETE /api/delete/{id}
```

---

#### 功能标志

**获取功能标志** (GET /api/features)

```
GET /api/features
```

---

#### 视图和媒体

**获取视图** (GET /api/view)

```
GET /api/view?filename={filename}
```

**获取视频** (GET /api/viewvideo)

```
GET /api/viewvideo?filename={filename}
```

---

## WebSocket API

WebSocket 连接用于实时通信和事件流。

### 连接

**URL**: `ws://{host}/ws?clientId={clientId}`

**协议**: WebSocket

### 消息类型

#### 状态消息 (status)

```typescript
interface StatusWsMessage {
  type: 'status'
  data: StatusWsMessageStatus
}
```

---

#### 执行消息

**执行开始** (execution_start)
```typescript
interface ExecutionStartWsMessage {
  type: 'execution_start'
  data: {
    prompt_id: string
  }
}
```

**执行中** (executing)
```typescript
interface ExecutingWsMessage {
  type: 'executing'
  data: {
    node: string | null
    prompt_id: string
  }
}
```

**执行成功** (execution_success)
```typescript
interface ExecutionSuccessWsMessage {
  type: 'execution_success'
  data: {
    prompt_id: string
    outputs: Record<string, any>
  }
}
```

**执行错误** (execution_error)
```typescript
interface ExecutionErrorWsMessage {
  type: 'execution_error'
  data: {
    prompt_id: string
    node_id: string
    exception_message: string
    exception_type: string
    traceback: string[]
  }
}
```

**执行中断** (execution_interrupted)
```typescript
interface ExecutionInterruptedWsMessage {
  type: 'execution_interrupted'
  data: {
    prompt_id: string
  }
}
```

**执行缓存** (execution_cached)
```typescript
interface ExecutionCachedWsMessage {
  type: 'execution_cached'
  data: {
    prompt_id: string
    outputs: Record<string, any>
    nodes: string[]
  }
}
```

---

#### 进度消息

**进度更新** (progress)
```typescript
interface ProgressWsMessage {
  type: 'progress'
  data: {
    value: number
    max: number
  }
}
```

**进度文本** (progress_text)
```typescript
interface ProgressTextWsMessage {
  type: 'progress_text'
  data: {
    text: string
  }
}
```

**进度状态** (progress_state)
```typescript
interface ProgressStateWsMessage {
  type: 'progress_state'
  data: {
    state: string
  }
}
```

---

#### 日志消息 (logs)

```typescript
interface LogsWsMessage {
  type: 'logs'
  data: {
    messages: LogMessage[]
  }
}
```

---

#### 预览消息

**二进制预览** (b_preview)
```typescript
interface BinaryPreviewMessage {
  type: 'b_preview'
  data: Blob
}
```

**带元数据的二进制预览** (b_preview_with_metadata)
```typescript
interface BinaryPreviewWithMetadataMessage {
  type: 'b_preview_with_metadata'
  data: {
    blob: Blob
    nodeId: string
    parentNodeId: string
    displayNodeId: string
    realNodeId: string
    promptId: string
  }
}
```

---

#### 功能标志消息 (feature_flags)

```typescript
interface FeatureFlagsWsMessage {
  type: 'feature_flags'
  data: Record<string, unknown>
}
```

---

#### 资源下载消息 (asset_download)

```typescript
interface AssetDownloadWsMessage {
  type: 'asset_download'
  data: {
    url: string
    filename: string
    // 其他下载相关字段
  }
}
```

---

#### 通知消息 (notification)

```typescript
interface NotificationWsMessage {
  type: 'notification'
  data: {
    title: string
    message: string
    severity?: string
  }
}
```

---

### WebSocket 事件处理

```typescript
// 监听特定消息类型
api.addEventListener('status', (event) => {
  const status = event.detail
})

api.addEventListener('executing', (event) => {
  const { node, prompt_id } = event.detail
})

api.addEventListener('execution_success', (event) => {
  const { prompt_id, outputs } = event.detail
})

api.addEventListener('execution_error', (event) => {
  const { prompt_id, node_id, exception_message } = event.detail
})

api.addEventListener('progress', (event) => {
  const { value, max } = event.detail
})

// 发送 WebSocket 消息
api.socket?.send(JSON.stringify({
  type: 'interrupt',
  data: {}
}))
```

---

## 错误处理

### 通用错误处理模式

所有服务都遵循相似的错误处理模式：

```typescript
const handleApiError = (
  err: unknown,
  context: string,
  routeSpecificErrors?: Record<number, string>
): string => {
  if (!axios.isAxiosError(err)) {
    return err instanceof Error
      ? `${context}: ${err.message}`
      : `${context}: Unknown error occurred`
  }

  const axiosError = err as AxiosError<ErrorResponse>

  if (axiosError.response) {
    const { status, data } = axiosError.response

    // 检查路由特定的错误消息
    if (routeSpecificErrors?.[status]) {
      return routeSpecificErrors[status]
    }

    // 标准 HTTP 状态错误
    switch (status) {
      case 400:
        return `Bad request: ${data?.message || 'Invalid input'}`
      case 401:
        return 'Unauthorized: Authentication required'
      case 403:
        return `Forbidden: ${data?.message || 'Access denied'}`
      case 404:
        return `Not found: ${data?.message || 'Resource not found'}`
      case 500:
        return `Server error: ${data?.message || 'Internal server error'}`
      default:
        return `${context}: ${data?.message || axiosError.message}`
    }
  }

  return `${context}: ${axiosError.message}`
}
```

### 中止信号支持

大多数 API 方法都支持 `AbortSignal` 用于取消请求：

```typescript
const controller = new AbortController()

// 发送请求
const promise = service.search(
  { search: 'controlnet' },
  controller.signal
)

// 取消请求
setTimeout(() => controller.abort(), 5000)
```

---

## 认证

### Firebase 认证（Cloud）

对于 Cloud 部署，使用 Firebase JWT 令牌：

```typescript
// 自动处理 - Firebase 令牌自动添加到所有请求
const authHeader = await authStore.getAuthHeader()
// {
//   'Authorization': 'Bearer {jwt_token}',
//   // 其他认证头
// }
```

### API 密钥认证

某些服务接受 API 密钥：

```typescript
api.apiKey = 'your-api-key'
// 在请求中使用
```

### Comfy Org 认证

对于 Comfy Org 账户：

```typescript
// 在队列提示时使用
api.authToken = 'auth-token'
api.apiKey = 'api-key'

// 在工作流的 extra_data 中自动包含
```

### 用户标识

所有请求都包含 `Comfy-User` 头：

```typescript
api.user = 'username'
// 自动添加到所有请求：
// Comfy-User: username
```

---

## 使用示例

### 搜索节点

```typescript
import { useComfyRegistryService } from '@/services/comfyRegistryService'

const service = useComfyRegistryService()

// 搜索节点
const results = await service.search({
  search: 'controlnet',
  limit: 20
})

if (results) {
  console.log('搜索结果:', results)
} else {
  console.error('搜索失败:', service.error.value)
}
```

### 获取用户事件

```typescript
import { useCustomerEventsService } from '@/services/customerEventsService'

const service = useCustomerEventsService()

const events = await service.getMyEvents()
if (events) {
  events.events.forEach(event => {
    console.log(`${event.event_type}: ${service.formatEventType(event.event_type)}`)
  })
} else {
  console.error('获取事件失败:', service.error.value)
}
```

### 队列提示（执行工作流）

```typescript
import { api } from '@/scripts/api'

const workflow = {
  // ... 工作流定义
}

try {
  const response = await api.queuePrompt(workflow)
  console.log('提示 ID:', response.prompt_id)
  console.log('队列号:', response.number)
} catch (error) {
  console.error('队列失败:', error)
}
```

### 监听执行事件

```typescript
import { api } from '@/scripts/api'

api.addEventListener('execution_start', (event) => {
  console.log('执行开始:', event.detail.prompt_id)
})

api.addEventListener('executing', (event) => {
  console.log('执行节点:', event.detail.node)
})

api.addEventListener('execution_success', (event) => {
  console.log('执行成功:', event.detail.prompt_id)
  console.log('输出:', event.detail.outputs)
})

api.addEventListener('execution_error', (event) => {
  console.error('执行错误:', event.detail.exception_message)
})

api.addEventListener('progress', (event) => {
  const { value, max } = event.detail
  console.log(`进度: ${value}/${max}`)
})
```

### 管理工作区

```typescript
import { workspaceApi } from '@/platform/workspace/api/workspaceApi'

// 列出工作区
const workspaces = await workspaceApi.list()

// 创建工作区
const newWorkspace = await workspaceApi.create({
  name: 'My Workspace'
})

// 邀请成员
const invite = await workspaceApi.createInvite({
  email: 'user@example.com'
})

// 列出成员
const members = await workspaceApi.listMembers()
```

---

## 注释和配置

- 所有 API 调用都可以被中止（通过 `AbortSignal`）
- 错误自动处理并存储在服务的 `error.value` 中
- 加载状态通过 `isLoading.value` 追踪
- 所有网络请求都使用 axios 客户端
- 类型安全由 OpenAPI 生成的类型提供
- WebSocket 连接自动管理重连

---

**最后更新**: 2024
**文档版本**: 1.0
