#!/bin/bash

echo "==> Configuring Xwrapper permissions..."
sudo mkdir -p /etc/X11
echo "allowed_users=anybody" | sudo tee /etc/X11/Xwrapper.config > /dev/null
