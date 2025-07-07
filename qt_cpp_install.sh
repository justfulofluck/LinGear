#!/bin/bash

# Exit the script immediately if any command fails
set -e

# ------------------------------------------------------------------------------
# 🔹 Detect Logged-In User
# ------------------------------------------------------------------------------

USER_NAME=$(logname)
USER_HOME="/home/$USER_NAME"

APP_PATH="$USER_HOME/hello_qt"
START_KIOSK_SH="/usr/local/bin/start-kiosk.sh"
KIOSK_APP_SH="/usr/local/bin/kiosk-app.sh"

# ------------------------------------------------------------------------------
# 🔹 Install Minimal X11 Environment and Qt5 Development Stack
# ------------------------------------------------------------------------------

echo "==> Installing required packages for GUI and Qt development..."
sudo apt update

sudo apt install -y \
    xserver-xorg \
    xinit \
    openbox \
    qtbase5-dev \
    qttools5-dev \
    qtchooser \
    build-essential

# xserver-xorg        = Core X11 display server
# xinit               = Utility to start X sessions
# openbox             = Lightweight window manager
# qtbase5-dev         = Qt5 C++ core development libraries
# qttools5-dev        = Qt Designer and tools
# qtchooser           = Manage multiple Qt versions
# build-essential     = GCC, g++, make, etc.

# ------------------------------------------------------------------------------
# 🔹 Create Startup Scripts for Kiosk
# ------------------------------------------------------------------------------

echo "==> Creating X startup script (start-kiosk.sh)..."
sudo tee "$START_KIOSK_SH" > /dev/null <<EOF
#!/bin/bash
xinit $KIOSK_APP_SH -- :0
EOF
sudo chmod +x "$START_KIOSK_SH"

echo "==> Creating kiosk app launcher (kiosk-app.sh)..."
sudo tee "$KIOSK_APP_SH" > /dev/null <<EOF
#!/bin/bash
openbox &                  # Start Openbox WM
exec $APP_PATH             # Run the Qt app
EOF
sudo chmod +x "$KIOSK_APP_SH"

# ------------------------------------------------------------------------------
# 🔹 Create systemd Service to Launch on Boot
# ------------------------------------------------------------------------------

echo "==> Creating systemd service for kiosk mode..."
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

# ------------------------------------------------------------------------------
# 🔹 Optional: Disable Login Manager
# ------------------------------------------------------------------------------

echo "==> Disabling graphical login manager (if present)..."
sudo systemctl disable lightdm || true

# ------------------------------------------------------------------------------
# 🔹 Enable Auto-login on TTY1
# ------------------------------------------------------------------------------

echo "==> Enabling autologin on virtual console tty1..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER_NAME --noclear %I \$TERM
EOF

# ------------------------------------------------------------------------------
# 🔹 Configure Xwrapper to Allow All Users to Start X Server
# ------------------------------------------------------------------------------

echo "==> Setting Xwrapper to allow any user to start X..."
sudo mkdir -p /etc/X11
echo "allowed_users=anybody" | sudo tee /etc/X11/Xwrapper.config > /dev/null

# ------------------------------------------------------------------------------
# 🔹 Build Qt Hello World Application
# ------------------------------------------------------------------------------

echo "==> Creating and compiling Qt kiosk application..."
mkdir -p "$USER_HOME/qt-kiosk-app"
cd "$USER_HOME/qt-kiosk-app"

# Create main.cpp
cat > main.cpp << 'EOF'
#include <QApplication>
#include <QLabel>

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    QLabel label("Hello, World!");
    label.setAlignment(Qt::AlignCenter);
    label.resize(800, 480);
    label.setStyleSheet("font-size: 48px; color: white; background-color: black;");
    label.showFullScreen();

    return app.exec();
}
EOF

# Create hello_qt.pro (Qt project file)
cat > hello_qt.pro << 'EOF'
QT += core gui widgets

CONFIG += c++11

TARGET = hello_qt
TEMPLATE = app

SOURCES += main.cpp
EOF

# Build the Qt app
qmake hello_qt.pro
make

# Copy compiled binary to home and set permissions
sudo cp hello_qt "$APP_PATH"
sudo chmod +x "$APP_PATH"
sudo chown $USER_NAME:$USER_NAME "$APP_PATH"

# ------------------------------------------------------------------------------
# 🔹 Install Plymouth and Configure Boot Splash
# ------------------------------------------------------------------------------

echo "==> Installing Plymouth and custom splash theme..."
sudo apt install -y plymouth plymouth-themes git

# Clone and install selected theme
sudo mkdir -p "$USER_HOME/theme"
cd "$USER_HOME/theme"
sudo git clone https://github.com/adi1090x/plymouth-themes.git
sudo cp -r plymouth-themes/pack_4/spinner_alt /usr/share/plymouth/themes/
sudo chown -R $USER_NAME:$USER_NAME "$USER_HOME/theme"

# Set selected theme
sudo update-alternatives --install \
  /usr/share/plymouth/themes/default.plymouth default.plymouth \
  /usr/share/plymouth/themes/spinner_alt/spinner_alt.plymouth 100

sudo update-alternatives --set default.plymouth \
  /usr/share/plymouth/themes/spinner_alt/spinner_alt.plymouth

sudo update-initramfs -u

# ------------------------------------------------------------------------------
# 🔹 Modify GRUB to Enable Splash Screen
# ------------------------------------------------------------------------------

echo "==> Modifying GRUB boot parameters..."
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub
sudo update-grub

# ------------------------------------------------------------------------------
# 🔹 Configure Autologin on TTY1
# ------------------------------------------------------------------------------

# Get current user
USER_NAME=$(logname)
USER_HOME="/home/$USER_NAME"
TTY_OVERRIDE_DIR="/etc/systemd/system/getty@tty1.service.d"
TTY_OVERRIDE_FILE="$TTY_OVERRIDE_DIR/override.conf"
BASH_PROFILE="$USER_HOME/.bash_profile"
KIOSK_SCRIPT="/usr/local/bin/kiosk-app.sh"

# Step 1: Enable autologin on tty1
echo "🔧 Configuring auto-login on tty1..."
sudo mkdir -p "$TTY_OVERRIDE_DIR"

sudo tee "$TTY_OVERRIDE_FILE" > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER_NAME --noclear %I \$TERM
EOF

# Step 2: Add kiosk start logic to ~/.bash_profile
echo "🖥️  Creating or updating ~/.bash_profile..."
if ! grep -q "startx $KIOSK_SCRIPT" "$BASH_PROFILE" 2>/dev/null; then
  cat >> "$BASH_PROFILE" <<EOF

# Auto-start kiosk on tty1
if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    startx $KIOSK_SCRIPT
fi
EOF
else
  echo "ℹ️  ~/.bash_profile already configured."
fi

# Step 3: Disable systemd service if it exists
echo "🧹 Disabling kiosk.service (if exists)..."
sudo systemctl disable kiosk.service || true

# ------------------------------------------------------------------------------
# ✅ Done
# ------------------------------------------------------------------------------

echo "✅ Setup complete. Reboot your system to launch kiosk mode!"
