#!/bin/bash

echo "==> Creating systemd kiosk service..."

sudo tee /etc/systemd/system/kiosk.service > /dev/null <<EOF
[Unit]
Description=Qt Kiosk Mode
After=network.target

[Service]
Type=simple
User=$USER_NAME
Environment=HOME=$USER_HOME
ExecStart=$START_KIOSK_SH
Restart=always

[Install]
WantedBy=graphical.target
EOF

sudo systemctl enable kiosk.service
sudo systemctl start kiosk.service
