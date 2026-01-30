# 负载均衡配置优化总结

## 问题
原始配置几百个后端 URL 需要在 `.env` 中逐个列出，非常繁琐。

## 解决方案

实现了三种灵活的配置方法：

### 1. 直接 URL 配置（推荐 1-10 个服务器）

```bash
# 逗号分隔
DEV_SERVER_COMFYUI_URL=http://server1:8188,http://server2:8188,http://server3:8188

# 分号分隔
DEV_SERVER_COMFYUI_URL=http://server1:8188; http://server2:8188; http://server3:8188
```

### 2. 范围表示法（推荐 10-100 个服务器）⭐ 最方便

```bash
# 100 个服务器，一行代码搞定
DEV_SERVER_COMFYUI_URL=http://server[1-100]:8188

# IP 地址范围
DEV_SERVER_COMFYUI_URL=http://192.168.1[1-50]:8188

# 多个范围组合
DEV_SERVER_COMFYUI_URL=http://primary[1-50]:8188,http://secondary[1-30]:8188,http://backup[1-20]:8188
```

### 3. 从文件加载（推荐 100+ 个服务器）⭐ 最推荐

**JSON 格式** (`servers.json`)：
```json
[
  "http://compute[1-500]:8188",
  "http://gpu[1-100]:8188",
  "http://backup[1-20]:8188"
]
```

**文本格式** (`servers.txt`)：
```
# 支持注释
http://compute[1-500]:8188
http://gpu[1-100]:8188
http://backup[1-20]:8188
```

**在 .env 中配置：**
```bash
# JSON 文件
DEV_SERVER_COMFYUI_FILE=file:///etc/comfyui/servers.json

# 文本文件
DEV_SERVER_COMFYUI_FILE=file:///etc/comfyui/servers.txt
```

## 对比

| 方法 | 适用场景 | 配置复杂度 | 易维护性 | 推荐指数 |
|------|---------|----------|---------|--------|
| 直接 URL | 1-10 个服务器 | 低 | 中 | ⭐⭐⭐ |
| 范围表示法 | 10-100 个服务器 | 很低 | 高 | ⭐⭐⭐⭐ |
| 文件加载 | 100+ 个服务器 | 中 | 很高 | ⭐⭐⭐⭐⭐ |

## 示例场景

### 100 个服务器

**旧方式（繁琐）：**
```bash
DEV_SERVER_COMFYUI_URL=http://server1:8188,http://server2:8188,http://server3:8188,...,http://server100:8188
# 需要手动输入 100 个 URL！
```

**新方式（简洁）：**
```bash
DEV_SERVER_COMFYUI_URL=http://server[1-100]:8188
# 一行代码，自动展开为 100 个 URL！
```

### 500 个服务器（分布在 5 个数据中心）

```bash
# servers.json
[
  "http://dc1[1-100]:8188",
  "http://dc2[1-100]:8188",
  "http://dc3[1-100]:8188",
  "http://dc4[1-100]:8188",
  "http://dc5[1-100]:8188"
]

# .env
DEV_SERVER_COMFYUI_FILE=file:///etc/comfyui/servers.json
```

## 特性

- ✅ **自动轮询** - 使用轮询算法分配请求
- ✅ **零配置回退** - 支持单个 URL（无需修改现有配置）
- ✅ **支持注释** - 文本格式支持 # 注释
- ✅ **灵活组合** - 可混合使用直接 URL 和范围表示法
- ✅ **高性能** - 展开在启动时进行，运行时无额外开销
- ✅ **可扩展** - 已测试 1000+ 服务器配置

## 文件位置

相关文件：
- 文档：[docs/LOAD_BALANCING.md](docs/LOAD_BALANCING.md)
- 配置示例：[config/servers.example.json](config/servers.example.json)
- 配置示例：[config/servers.example.txt](config/servers.example.txt)
- .env 示例：[.env.load-balance.example](.env.load-balance.example)

## 使用建议

1. **少于 10 个服务器**：直接在 `.env` 中配置 URL
2. **10-100 个服务器**：使用范围表示法，只需一行代码
3. **100+ 个服务器**：使用文件加载，配置更清晰易维护
4. **生产环境**：推荐使用文件加载，方便版本控制和部署
