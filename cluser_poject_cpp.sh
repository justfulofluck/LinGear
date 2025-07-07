#!/bin/bash

# Exit the script immediately if any command fails
set -e

# --------------------------------------------------------------------
# 🔹 Detect Logged-In User
# --------------------------------------------------------------------
USER_NAME=$(logname)
USER_HOME="/home/$USER_NAME"
APP_PATH="$USER_HOME/Qt-HMI-Display-UI/Car_1"
START_KIOSK_SH="/usr/local/bin/start-kiosk.sh"
KIOSK_APP_SH="/usr/local/bin/kiosk-app.sh"

# --------------------------------------------------------------------
# 🔹 Install Minimal X11 Environment and Qt5 Development Stack
# --------------------------------------------------------------------
echo "==> Installing required packages..."
sudo apt update
sudo apt install -y \
    xserver-xorg \
    xinit \
    openbox \
    qtbase5-dev \
    qtdeclarative5-dev \
    qtquickcontrols2-5-dev \
    qttools5-dev \
    qtchooser \
    build-essential \
    git \
    qml-module-qtquick-controls \
    qml-module-qtquick2 \
    qml-module-qtpositioning \
    qml-module-qtlocation

# --------------------------------------------------------------------
# 🔹 Clone and Build Qt HMI Display UI App
# --------------------------------------------------------------------
echo "==> Cloning and building Qt-HMI-Display-UI project..."
cd "$USER_HOME"
git clone https://github.com/cppqtdev/Qt-HMI-Display-UI.git || true
cd Qt-HMI-Display-UI
qmake Car_1.pro
make
sudo chmod +x "$APP_PATH"
sudo chown "$USER_NAME:$USER_NAME" "$APP_PATH"

# --------------------------------------------------------------------
# 🔹 Create X Startup Scripts
# --------------------------------------------------------------------
echo "==> Creating X startup scripts..."
sudo tee "$START_KIOSK_SH" > /dev/null <<EOF
#!/bin/bash
xinit $KIOSK_APP_SH -- :0
EOF
sudo chmod +x "$START_KIOSK_SH"

sudo tee "$KIOSK_APP_SH" > /dev/null <<EOF
#!/bin/bash
openbox &    # Start lightweight window manager
exec $APP_PATH
EOF
sudo chmod +x "$KIOSK_APP_SH"

# --------------------------------------------------------------------
# 🔹 Create systemd Service for Boot Launch
# --------------------------------------------------------------------
echo "==> Creating systemd service for kiosk app..."
sudo tee /etc/systemd/system/kiosk.service > /dev/null <<EOF
[Unit]
Description=Qt HMI Kiosk Mode
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

# --------------------------------------------------------------------
# 🔹 Optional: Disable Graphical Login Manager
# --------------------------------------------------------------------
echo "==> Disabling graphical login manager (if present)..."
sudo systemctl disable lightdm || true

# --------------------------------------------------------------------
# 🔹 Enable Auto-login on TTY1
# --------------------------------------------------------------------
echo "==> Enabling autologin on TTY1..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER_NAME --noclear %I \$TERM
EOF

# --------------------------------------------------------------------
# 🔹 Configure Xwrapper to Allow All Users to Start X
# --------------------------------------------------------------------
echo "==> Configuring Xwrapper..."
sudo mkdir -p /etc/X11
echo "allowed_users=anybody" | sudo tee /etc/X11/Xwrapper.config > /dev/null

# --------------------------------------------------------------------
# ✅ DONE
# --------------------------------------------------------------------
echo "✅ Setup complete! Reboot your system to launch Qt HMI in kiosk mode."
