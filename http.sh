#!/bin/bash

rand_str() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 8
}

# 默认参数：随机生成
PORT=${1:-$((RANDOM % 20000 + 10000))}
USER=${2:-$(rand_str)}
PASS=${3:-$(rand_str)}

# 安装 GOST
wget -q https://github.com/kangcwei/proxy/releases/download/proxy/proxy -O /usr/local/bin/proxy
chmod +x /usr/local/bin/proxy

# 写 systemd 服务
cat >/etc/systemd/system/proxy.service <<EOF
[Unit]
Description=GOST HTTP Proxy
After=network.target

[Service]
ExecStart=/usr/local/bin/proxy -L=http://${USER}:${PASS}@:${PORT}
Restart=always
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reexec
systemctl enable proxy
systemctl restart proxy

# 获取服务器IP
SERVER_IP=$(curl  ifconfig.me)

echo -e "\033[1;32m✅ HTTP 代理已启动\033[0m"
echo -e "\033[1;34m--------------------------------------\033[0m"
echo -e "地址: \033[1;33m${SERVER_IP}:${PORT}\033[0m"
echo -e "用户名: \033[1;36m${USER}\033[0m"
echo -e "密码: \033[1;31m${PASS}\033[0m"
echo -e "完整代理URL: \033[1;35mhttp://${USER}:${PASS}@${SERVER_IP}:${PORT}\033[0m"
echo -e "\033[1;34m--------------------------------------\033[0m"

