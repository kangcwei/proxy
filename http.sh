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

echo " HTTP 代理已启动"
echo "--------------------------------------"
echo "地址: ${SERVER_IP}:${PORT}"
echo "用户名: ${USER}"
echo "密码: ${PASS}"
echo "完整代理URL: http://${USER}:${PASS}@${SERVER_IP}:${PORT}"
echo "--------------------------------------"
