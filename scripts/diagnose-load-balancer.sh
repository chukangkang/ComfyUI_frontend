#!/bin/bash
# 负载均衡诊断脚本

echo "========== ComfyUI 负载均衡诊断 =========="
echo

echo "1. 检查 servers.json 配置..."
if [ -f "/root/ComfyUI_frontend/servers.json" ]; then
    echo "✓ 文件存在"
    echo "内容："
    cat /root/ComfyUI_frontend/servers.json
    echo
else
    echo "✗ 文件不存在: /root/ComfyUI_frontend/servers.json"
    exit 1
fi

echo "2. 验证 JSON 格式..."
python3 -c "
import json
try:
    with open('/root/ComfyUI_frontend/servers.json', 'r') as f:
        data = json.load(f)
    if isinstance(data, list):
        print(f'✓ JSON 格式正确 - 数组包含 {len(data)} 个服务器')
        for i, url in enumerate(data, 1):
            print(f'  {i}. {url}')
    else:
        print('✗ JSON 格式错误 - 必须是数组 [...]')
except Exception as e:
    print(f'✗ JSON 解析失败: {e}')
" 2>&1
echo

echo "3. 检查 .env 配置..."
grep "DEV_SERVER_COMFYUI" /root/ComfyUI_frontend/.env | grep -v "^#"
echo

echo "4. 测试后端服务器连接..."
python3 -c "
import json
import subprocess

with open('/root/ComfyUI_frontend/servers.json', 'r') as f:
    servers = json.load(f)

for server in servers:
    result = subprocess.run(
        ['curl', '-s', '-m', '5', '-o', '/dev/null', '-w', '%{http_code}', f'{server}/api/'],
        capture_output=True
    )
    status = result.stdout.decode().strip()
    if status in ['200', '404', '500']:
        print(f'✓ {server} - HTTP {status}')
    else:
        print(f'✗ {server} - 连接失败 (状态码: {status})')
" 2>&1
echo

echo "5. 哈希算法验证..."
python3 << 'EOF'
import json

with open('/root/ComfyUI_frontend/servers.json', 'r') as f:
    servers = json.load(f)

# 模拟几个客户端 IP 的路由分配
test_ips = [
    '127.0.0.1',
    '192.168.1.100',
    '192.168.1.101',
    '192.168.1.102',
    '10.0.0.1',
]

print("客户端 IP → 分配服务器:")
for ip in test_ips:
    hash_val = sum(ord(c) for c in ip)
    index = hash_val % len(servers)
    print(f"  {ip:20} → {servers[index]}")
EOF
echo

echo "========== 诊断完成 =========="
