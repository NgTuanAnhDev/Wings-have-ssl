#!/bin/bash
#Tool Made By Nguyentuananh.enternal
#Bản quyền thuộc Dptcloud.vn

clear
echo "Bắt đầu cài đặt Wings Daemon..."
curl -sSL https://get.docker.com/ | CHANNEL=stable bash
systemctl enable --now docker
GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1"
mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
chmod u+x /usr/local/bin/wings

echo "Cấu hình Wings..."

echo "[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/wings.service
read -p "Nhập token Panel: " token
read -p "Nhập tên miền của bạn (ví dụ: example.com): " domain
read -p "Nhập STT Node: " node

echo "Bắt đầu cài đặt SSL cho Wings..."
apt update
apt install -y certbot
certbot certonly --standalone --agree-tos --redirect --staple-ocsp --email admin@dptcloud.vn -d $domain
certbot renew --dry-run

echo "Cấu hình Wings sử dụng SSL..."

cd /etc/pterodactyl && sudo wings configure --panel-url https://gaming.dptcloud.vn --token $token --node $node
systemctl enable wings.service
systemctl start wings.service

echo "Xong! Wings Daemon đã được cài đặt, SSL đã được cấu hình cho tên miền $domain, và token đã được cấu hình."
