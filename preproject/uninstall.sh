#!/bin/bash

# Exit on errors
set -e

# -------------------------------------------------------------------
# 🔹 Define Constants and User Variables
# -------------------------------------------------------------------

USER_NAME=$(logname)
USER_HOME="/home/$USER_NAME"

APP_PATH="$USER_HOME/hello_qt"
KIOSK_APP_SH="/usr/local/bin/kiosk-app.sh"
START_KIOSK_SH="/usr/local/bin/start-kiosk.sh"
KIOSK_SERVICE="/etc/systemd/system/kiosk.service"

QT_APP_DIR="$USER_HOME/qt-kiosk-app"
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/spinner_alt"
CUSTOM_THEME_CLONE="$USER_HOME/theme"

# -------------------------------------------------------------------
# 🔹 Stop and Disable Kiosk Service
# -------------------------------------------------------------------

echo "==> Disabling and removing kiosk systemd service..."
sudo systemctl stop kiosk.service || true
sudo systemctl disable kiosk.service || true
sudo rm -f "$KIOSK_SERVICE"

# -------------------------------------------------------------------
# 🔹 Restore getty autologin (optional: revert override)
# -------------------------------------------------------------------

echo "==> Restoring TTY1 getty service configuration..."
sudo rm -rf /etc/systemd/system/getty@tty1.service.d

# -------------------------------------------------------------------
# 🔹 Remove Startup Scripts
# -------------------------------------------------------------------

echo "==> Removing kiosk startup scripts..."
sudo rm -f "$START_KIOSK_SH" "$KIOSK_APP_SH"

# -------------------------------------------------------------------
# 🔹 Remove Qt App and Source Code
# -------------------------------------------------------------------

echo "==> Removing Qt application binary and source files..."
rm -rf "$APP_PATH" "$QT_APP_DIR"

# -------------------------------------------------------------------
# 🔹 Uninstall Packages
# -------------------------------------------------------------------

echo "==> Uninstalling installed packages..."
sudo apt remove --purge -y \
    xserver-xorg \
    xinit \
    openbox \
    qtbase5-dev \
    qttools5-dev \
    qtchooser \
    build-essential \
    plymouth \
    plymouth-themes \
    git

sudo apt autoremove --purge -y
sudo apt clean

# -------------------------------------------------------------------
# 🔹 Restore Xwrapper Configuration (if needed)
# -------------------------------------------------------------------

echo "==> Restoring default Xwrapper configuration..."
sudo rm -f /etc/X11/Xwrapper.config

# -------------------------------------------------------------------
# 🔹 Restore GRUB Settings
# -------------------------------------------------------------------

echo "==> Reverting GRUB boot parameters..."
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/' /etc/default/grub
sudo update-grub

# -------------------------------------------------------------------
# 🔹 Remove Plymouth Theme
# -------------------------------------------------------------------

echo "==> Removing custom Plymouth theme..."
sudo rm -rf "$PLYMOUTH_THEME_DIR"
rm -rf "$CUSTOM_THEME_CLONE"
sudo update-initramfs -u

# -------------------------------------------------------------------
# ✅ Done
# -------------------------------------------------------------------

echo "✅ Uninstallation complete. You may reboot to revert fully to normal login."
