#!/bin/bash

echo "==> Setting up kiosk permissions..."

# Create kiosk group if it doesn't exist
sudo groupadd -f $KIOSK_GROUP

# Add current user to kiosk group
sudo usermod -aG $KIOSK_GROUP $USER_NAME

# Create directories with appropriate permissions
sudo mkdir -p /usr/local/bin
sudo mkdir -p /etc/X11
sudo mkdir -p /etc/systemd/system

# Set group ownership for key directories
sudo chown -R root:$KIOSK_GROUP /usr/local/bin
sudo chmod -R 775 /usr/local/bin

echo "==> Kiosk permissions set up successfully."