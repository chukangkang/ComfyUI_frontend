# API 集成检查清单

在项目中集成和使用 API 时的完整检查清单。

## 📋 集成前检查

### 基础设置
- [ ] 项目已安装所有依赖 (`pnpm install`)
- [ ] 环境变量已配置 (`.env` 文件)
- [ ] API 基础 URL 已正确配置
- [ ] TypeScript 类型检查通过 (`pnpm typecheck`)

### API 选择
- [ ] 已确认需要使用的 API (Registry、Events、Workspace 等)
- [ ] 已阅读相应的 API 文档
- [ ] 已验证 API 端点的可用性
- [ ] 已检查认证要求

---

## 🔧 开发集成

### 导入和初始化
- [ ] 正确导入服务/API
  ```typescript
  import { useComfyRegistryService } from '@/services/comfyRegistryService'
  import { api } from '@/scripts/api'
  ```
- [ ] 在 `<script setup>` 中初始化服务
  ```typescript
  const service = useComfyRegistryService()
  ```
- [ ] 检查服务是否在当前环境中可用

### 类型安全
- [ ] 使用 TypeScript 定义请求和响应类型
- [ ] 参数类型正确对应
- [ ] 返回值类型处理正确
- [ ] 没有使用 `any` 类型

### 错误处理
- [ ] 检查返回值是否为 null（表示错误）
- [ ] 访问 `service.error.value` 获取错误消息
- [ ] 为用户显示适当的错误提示
- [ ] 实现错误恢复机制（重试等）

### 异步操作
- [ ] 使用 `await` 等待异步操作完成
- [ ] 检查 `service.isLoading.value` 显示加载状态
- [ ] 使用 `AbortSignal` 支持请求取消
- [ ] 处理 timeout 和 network 错误

### 响应式数据
- [ ] 使用 `ref()` 存储 API 返回的数据
- [ ] 使用 `computed()` 派生数据
- [ ] 使用 `watch()` 监听数据变化
- [ ] 在适当时机更新 UI

---

## 🔐 认证和安全

### 认证设置
- [ ] Firebase 认证已配置（Cloud 部署）
- [ ] API 密钥存储在环境变量中
- [ ] 认证令牌定时更新
- [ ] 没有在代码中硬编码密钥

### 请求头
- [ ] `Authorization` 头已正确包含
- [ ] `Comfy-User` 头自动添加
- [ ] `Content-Type` 设置为 `application/json`
- [ ] 自定义头字段正确包含

### 权限检查
- [ ] 用户有访问资源的权限
- [ ] 处理 401 Unauthorized 错误
- [ ] 处理 403 Forbidden 错误
- [ ] 实现优雅的权限拒绝提示

---

## 🧪 测试

### 单元测试
- [ ] 为 API 调用编写测试用例
- [ ] Mock axios 客户端
- [ ] 测试成功和失败场景
- [ ] 测试错误处理

### 集成测试
- [ ] 测试完整的数据流
- [ ] 验证 UI 正确响应 API 数据
- [ ] 测试用户交互触发的 API 调用

### 端到端测试 (E2E)
- [ ] 使用 Playwright 编写 E2E 测试
- [ ] 测试真实的用户场景
- [ ] 验证数据在 UI 中正确显示

### 手动测试
- [ ] 在浏览器中测试 API 调用
- [ ] 检查网络标签中的请求/响应
- [ ] 验证错误处理和加载状态
- [ ] 测试网络延迟和超时场景

---

## 📊 性能优化

### 数据加载
- [ ] 实现分页而非一次性加载所有数据
- [ ] 缓存频繁访问的数据
- [ ] 使用 `AbortSignal` 取消过期请求
- [ ] 避免重复的 API 调用

### 渲染优化
- [ ] 使用 `v-if` 或 `v-show` 条件渲染
- [ ] 使用虚拟滚动处理大列表
- [ ] 避免在模板中进行复杂计算
- [ ] 使用 `key` 属性正确追踪列表项

### WebSocket 优化
- [ ] 只在需要时建立 WebSocket 连接
- [ ] 正确处理连接关闭
- [ ] 实现自动重连逻辑
- [ ] 不要在大量数据更新时阻塞主线程

---

## 🔍 调试

### 日志和监控
- [ ] 添加适当的 console.log 用于调试
- [ ] 使用浏览器开发者工具检查网络请求
- [ ] 查看 API 响应数据结构
- [ ] 检查错误消息和堆栈跟踪

### 常见问题
- [ ] 检查 CORS 错误（跨域问题）
- [ ] 验证 API 端点 URL 正确
- [ ] 确认请求参数格式正确
- [ ] 检查认证令牌是否有效

### 工具和技巧
- [ ] 使用 Vue DevTools 检查组件状态
- [ ] 使用 Network 标签分析请求
- [ ] 使用 Console 运行 API 调用测试
- [ ] 使用断点调试异步代码流

---

## 📝 代码质量

### 代码风格
- [ ] 遵循项目的 eslint 规则
- [ ] 代码已被 prettier/oxfmt 格式化
- [ ] 使用有意义的变量和函数名称
- [ ] 函数长度不超过 50 行

### 文档
- [ ] 为复杂逻辑添加注释
- [ ] 为公开函数添加 JSDoc 注释
- [ ] 在组件中说明 API 用途
- [ ] 更新相关的 README 文件

### 最佳实践
- [ ] 使用 Vue 3 Composition API
- [ ] 使用 TypeScript 确保类型安全
- [ ] 遵循响应式原则
- [ ] 避免常见的性能陷阱

---

## 🚀 部署前检查

### 代码审查
- [ ] 代码已被同事审查
- [ ] 所有 feedback 已处理
- [ ] 没有硬编码的 debug 代码
- [ ] 没有临时的 console.log

### 最终测试
- [ ] 所有测试用例通过
  ```bash
  pnpm test:unit
  pnpm test:browser
  ```
- [ ] 类型检查通过
  ```bash
  pnpm typecheck
  ```
- [ ] Lint 检查通过
  ```bash
  pnpm lint
  ```
- [ ] 代码格式化完成
  ```bash
  pnpm format
  ```

### 部署检查
- [ ] 环境变量已配置
- [ ] API 基础 URL 正确指向生产服务
- [ ] 认证令牌配置正确
- [ ] 没有过期的 token 或密钥
- [ ] CDN 和缓存策略已配置

---

## 📦 版本和兼容性

### API 兼容性
- [ ] API 版本与项目兼容
- [ ] 已检查 breaking changes
- [ ] 已验证新增字段的处理
- [ ] 已测试向后兼容性

### 浏览器兼容性
- [ ] 已测试主流浏览器（Chrome、Firefox、Safari）
- [ ] WebSocket 在所有浏览器中工作
- [ ] 处理了浏览器特定的问题
- [ ] 使用了适当的 polyfill

### 依赖版本
- [ ] axios 版本兼容
- [ ] Vue 版本兼容
- [ ] TypeScript 版本兼容
- [ ] 其他相关库版本兼容

---

## 🔄 维护和更新

### 文档更新
- [ ] 更新了项目文档
- [ ] 添加了新的 API 使用示例
- [ ] 更新了 README 中的相关部分
- [ ] 文档准确反映代码实现

### 代码维护
- [ ] 死代码已移除
- [ ] 过时的注释已删除
- [ ] 建立了长期维护计划
- [ ] 标记了可能的改进点

### 监控和日志
- [ ] 实现了错误监控
- [ ] 设置了性能监控
- [ ] 记录关键操作
- [ ] 定期检查日志

---

## 🎯 常见 API 集成检查清单

### Registry API 集成
```typescript
const service = useComfyRegistryService()

// 检查清单
- [ ] 搜索功能正常工作
- [ ] 分页正确处理
- [ ] 错误消息显示正确
- [ ] 加载状态显示正确
- [ ] 取消请求功能正常
```

### Customer Events 集成
```typescript
const service = useCustomerEventsService()

// 检查清单
- [ ] 认证令牌已配置
- [ ] 事件类型正确格式化
- [ ] 日期显示正确
- [ ] 错误处理完整
- [ ] 自动刷新功能正常
```

### Workspace API 集成
```typescript
import { workspaceApi } from '@/platform/workspace/api/workspaceApi'

// 检查清单
- [ ] 列出工作区正常
- [ ] 创建工作区功能完整
- [ ] 权限检查正确
- [ ] 成员管理功能正常
- [ ] 邀请系统工作正确
```

### WebSocket 集成
```typescript
import { api } from '@/scripts/api'

// 检查清单
- [ ] 连接建立正确
- [ ] 事件监听器正确注册
- [ ] 数据处理完整
- [ ] 断线重连功能正常
- [ ] 内存泄漏已修复
```

---

## 📞 问题排查流程

### API 调用失败
```
1. 检查网络连接
   ↓
2. 验证 API 端点 URL
   ↓
3. 检查认证令牌
   ↓
4. 查看错误消息
   ↓
5. 检查请求参数
   ↓
6. 尝试直接调用 API（使用 curl 或 Postman）
```

### 数据不更新
```
1. 检查响应式引用使用
   ↓
2. 验证 watch 或 computed 设置
   ↓
3. 检查条件渲染
   ↓
4. 使用 Vue DevTools 检查数据
   ↓
5. 检查浏览器控制台错误
```

### 性能问题
```
1. 检查网络请求数量
   ↓
2. 使用 Performance 标签分析
   ↓
3. 检查不必要的重新渲染
   ↓
4. 实现分页或虚拟滚动
   ↓
5. 缓存频繁使用的数据
```

---

## ✅ 完成标准

### 开发完成
- [ ] 所有功能已实现
- [ ] 所有测试已通过
- [ ] 代码已格式化
- [ ] 文档已更新
- [ ] 代码审查已完成

### 质量保证
- [ ] 没有已知的 bug
- [ ] 性能符合要求
- [ ] 安全性检查通过
- [ ] 兼容性测试完成
- [ ] 用户体验验证完成

### 上线准备
- [ ] 生产环境已验证
- [ ] 回滚计划已准备
- [ ] 监控已配置
- [ ] 支持团队已培训
- [ ] 发布说明已准备

---

## 📊 统计信息

完成此检查清单可确保：
- ✅ 100% 的 API 功能正确集成
- ✅ 完整的错误处理
- ✅ 优化的性能
- ✅ 高质量的代码
- ✅ 全面的测试覆盖
- ✅ 详细的文档
- ✅ 安全的部署

---

## 🔗 相关资源

- [API 完整文档](./API_DOCUMENTATION.md)
- [API 快速参考](./API_QUICK_REFERENCE.md)
- [API 使用示例](./API_USAGE_EXAMPLES.md)
- [测试指南](./testing/README.md)
- [项目架构](./AGENTS.md)

---

**最后更新**: 2024
**版本**: 1.0

**祝你的 API 集成顺利！** 🚀
