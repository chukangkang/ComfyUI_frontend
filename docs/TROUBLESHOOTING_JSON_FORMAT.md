# JSON 配置错误 - 解决方案

## 问题描述

你配置了：
```json
{
  "http://ssh-hde.xingluan.cn:20040"
}
```

结果链接不上，日志显示 "Loaded 0 servers"。

## 根本原因

JSON 格式错误！这是一个 **对象 {}**，不是 **数组 []**。

## ✅ 正确解决方案

### 1. 修复 `/root/servers.json`

将文件内容改为：
```json
[
  "http://ssh-hde.xingluan.cn:20040"
]
```

或者用命令创建：
```bash
cat > /root/servers.json << 'EOF'
[
  "http://ssh-hde.xingluan.cn:20040"
]
EOF
```

### 2. 验证 JSON 格式

```bash
# 方式 1：Python 验证
python3 -c "import json; json.load(open('/root/servers.json')); print('✓ JSON 格式正确')"

# 方式 2：查看文件内容
cat /root/servers.json

# 方式 3：使用 jq（如果已安装）
cat /root/servers.json | jq .
```

### 3. 修改 `.env` 文件

```env
# 注释掉这一行（或删除）：
# DEV_SERVER_COMFYUI_URL=http://ssh-hde.xingluan.cn:20040

# 改用文件配置：
DEV_SERVER_COMFYUI_FILE=file:///root/servers.json
```

### 4. 重启开发服务器

启动后应该看到这样的日志：
```
[LoadBalancer] Loading servers from file: /root/servers.json
[LoadBalancer] Loaded 1 servers from JSON array
```

## 格式对比

### ❌ 错误格式

```json
// 这是对象，不是数组
{
  "http://server1:8188",
  "http://server2:8188"
}

// 这也是错的，缺少引号
[
  http://server1:8188,
  http://server2:8188
]

// 这也是错的，缺少中括号
"http://server1:8188",
"http://server2:8188"
```

### ✅ 正确格式

```json
// 单个 URL
[
  "http://ssh-hde.xingluan.cn:20040"
]

// 多个 URL
[
  "http://server1:8188",
  "http://server2:8188",
  "http://server3:8188"
]

// 支持范围表示法
[
  "http://server[1-100]:8188",
  "http://backup[1-20]:8188"
]

// 混合使用
[
  "http://server1:8188",
  "http://server[2-50]:8188"
]
```

## 测试步骤

### 步骤 1：验证 JSON 文件

```bash
$ cat /root/servers.json
[
  "http://ssh-hde.xingluan.cn:20040"
]
```

### 步骤 2：验证后端服务可达

```bash
$ curl -v http://ssh-hde.xingluan.cn:20040/api/
# 应该返回 200 或其他有效响应，而不是连接拒绝
```

### 步骤 3：验证 .env 配置

```bash
$ grep -A2 "DEV_SERVER_COMFYUI" .env
# 应该看到 DEV_SERVER_COMFYUI_FILE 而不是 DEV_SERVER_COMFYUI_URL
```

### 步骤 4：启动开发服务器并检查日志

```bash
$ pnpm dev
# 在日志中查找：
# [LoadBalancer] Loading servers from file: /root/servers.json
# [LoadBalancer] Loaded 1 servers from JSON array
```

## 常见问题

**Q: 为什么之前用 DEV_SERVER_COMFYUI_URL=http://... 可以，现在不行？**
A: 这是两种不同的配置方式。DEV_SERVER_COMFYUI_URL 直接配置单个 URL，DEV_SERVER_COMFYUI_FILE 从文件读取。两者不要混用。

**Q: JSON 格式我不确定，有没有在线验证？**
A: 可以使用 https://jsonlint.com/ 验证。复制你的 JSON 内容，如果显示绿色就是正确的。

**Q: 支持注释吗？**
A: JSON 不支持注释。如果要注释，使用文本格式文件（.txt）。

**Q: 文本文件怎么配置？**
A: 创建 `/root/servers.txt`，一行一个 URL，支持 # 注释：
```
# 这是注释
http://ssh-hde.xingluan.cn:20040
# 更多服务器
http://server[1-100]:8188
```

然后在 `.env` 中：
```
DEV_SERVER_COMFYUI_FILE=file:///root/servers.txt
```

## 快速恢复

如果还是有问题，临时恢复为直接配置：

在 `.env` 中：
```env
DEV_SERVER_COMFYUI_URL=http://ssh-hde.xingluan.cn:20040
# DEV_SERVER_COMFYUI_FILE=file:///root/servers.json
```

这样应该能连接上。然后再逐步调试文件配置。
