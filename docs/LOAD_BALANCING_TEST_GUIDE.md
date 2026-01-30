# 负载均衡测试指南

## 你的配置

```json
[
  "http://ssh-hde.xingluan.cn:20040",
  "http://ssh-hde.xingluan.cn:62001"
]
```

**2 个后端服务器，使用**一致性哈希**算法分配。

## 为什么两个页面用同一个服务器？

### 旧算法的问题

如果两个浏览器标签页**来自同一个 IP 地址**（比如都是 127.0.0.1），它们会被分配到同一个服务器。

这是**正常行为**，因为：
- 同一个 IP 地址 = 同一个客户端
- 一致性哈希 = 同一个客户端总是连到同一个服务器
- 这样做的好处是：WebSocket 连接稳定，会话数据一致

### 什么情况下两个标签页会分配到不同服务器？

需要来自**不同 IP 地址**的请求：

```
客户端 IP: 127.0.0.1          → Hash: ... → 服务器 1
客户端 IP: 192.168.1.100      → Hash: ... → 服务器 2
客户端 IP: 10.0.0.1           → Hash: ... → 服务器 1
...
```

## 测试方案

### 方案 1：使用不同的客户端 PC

最简单的测试方法：

1. **PC1** 打开浏览器，访问：
   ```
   http://dev-machine-ip:5173
   ```
   
2. **PC2** 打开浏览器，访问：
   ```
   http://dev-machine-ip:5173
   ```

3. 查看 vite 开发服务器的日志，应该看到：
   ```
   [LoadBalancer] GET / → http://ssh-hde.xingluan.cn:20040 [client: 192.168.1.100]
   [LoadBalancer] GET / → http://ssh-hde.xingluan.cn:62001 [client: 192.168.1.101]
   ```

✅ 两个不同 PC 分别连到不同服务器

### 方案 2：使用 curl 模拟不同客户端

```bash
# 模拟客户端 1
curl -H "X-Forwarded-For: 192.168.1.100" http://localhost:5173/api/

# 模拟客户端 2
curl -H "X-Forwarded-For: 192.168.1.101" http://localhost:5173/api/

# 模拟客户端 3
curl -H "X-Forwarded-For: 192.168.1.102" http://localhost:5173/api/
```

观察日志，应该看到不同的客户端 IP 路由到不同的服务器。

### 方案 3：使用代理改变 IP

用不同的代理访问，每个代理会呈现不同的客户端 IP：

```bash
# 使用代理 1
curl -x proxy1.example.com:8080 http://dev-server:5173

# 使用代理 2
curl -x proxy2.example.com:8080 http://dev-server:5173
```

### 方案 4：本地模拟多个客户端（高级）

使用 Docker 或虚拟机，创建多个网络接口，各自请求开发服务器。

## 验证负载均衡是否工作

### 1. 查看日志

启动开发服务器：
```bash
cd /root/ComfyUI_frontend
pnpm dev
```

输出应该包含：
```
[LoadBalancer] Loading servers from file: /root/ComfyUI_frontend/servers.json
[LoadBalancer] Loaded 2 servers from JSON array
```

### 2. 监控请求分配

每个请求都会打印日志：
```
[LoadBalancer] GET /api/info → http://ssh-hde.xingluan.cn:20040 [client: 127.0.0.1]
[LoadBalancer] GET /api/queue → http://ssh-hde.xingluan.cn:20040 [client: 127.0.0.1]
[LoadBalancer] POST /api/prompt → http://ssh-hde.xingluan.cn:20040 [client: 127.0.0.1]
```

✅ 同一个客户端 IP 的所有请求都路由到同一个服务器

### 3. 使用诊断脚本

```bash
bash /root/ComfyUI_frontend/scripts/diagnose-load-balancer.sh
```

这会输出：
- servers.json 配置检查
- JSON 格式验证
- 后端服务器连接测试
- 哈希算法分配演示

## 负载均衡的工作原理回顾

### 一致性哈希公式

```
hash(client_ip) % server_count = server_index

示例：
  hash("192.168.1.100") = 19213
  19213 % 2 = 1
  → 路由到服务器 2
```

### 优势

| 情况 | 行为 |
|-----|------|
| 同一 PC，多个浏览器标签 | 都连到同一服务器 ✓ |
| 不同 PC，同一局域网 | 可能连到不同服务器 ✓ |
| 同一 PC，不同 VPN/代理 | 不同的客户端 IP → 不同的服务器 ✓ |
| WebSocket 连接 | 总是稳定连到同一服务器 ✓ |

## 常见问题

**Q: 为什么我的两个浏览器标签页连到同一个服务器？**
A: 因为它们都来自同一个客户端 IP（127.0.0.1）。这是正确的行为。如果要分配到不同服务器，需要来自不同的 IP 地址。

**Q: 这是不是意味着负载均衡没有工作？**
A: 不是。负载均衡工作正常。它确保：
- 同一客户端的所有请求都路由到同一服务器（保证会话一致性）
- 不同客户端的请求分配到不同服务器（实现真正的负载均衡）

**Q: 能否改为纯轮询（每个请求轮流分配到不同服务器）？**
A: 可以，但不推荐：
- 同一个浏览器的 WebSocket 连接会中断
- 会话数据可能丢失
- 导致数据不一致

建议保持当前的一致性哈希算法。

**Q: 如何测试真实的负载均衡效果？**
A: 从不同的物理 PC 访问，每个 PC 会有不同的客户端 IP，从而分配到不同的服务器。

## 总结

当前实现：
- ✅ 一致性哈希算法
- ✅ 基于客户端 IP 的会话粘性
- ✅ WebSocket 支持
- ✅ 日志输出详细

预期行为：
- 同一客户端 IP → 同一服务器（好事）
- 不同客户端 IP → 可能不同服务器（真正的负载均衡）

如果需要测试，请从不同的物理机器或不同的网络接口访问。
