#!/bin/bash

set -e

MODULES_DIR="./modules"

echo "🚀 Starting Kiosk Setup..."

# Trap errors and print message
trap 'echo "❌ Error occurred in: $CURRENT_STEP"; exit 1' ERR

# Step-by-step execution
CURRENT_STEP="detect_user.sh"
source "$MODULES_DIR/detect_user.sh"
echo "✅ Completed: $CURRENT_STEP"

CURRENT_STEP="install_packages.sh"
source "$MODULES_DIR/install_packages.sh"
echo "✅ Completed: $CURRENT_STEP"

CURRENT_STEP="create_kiosk_scripts.sh"
source "$MODULES_DIR/create_kiosk_scripts.sh"
echo "✅ Completed: $CURRENT_STEP"

CURRENT_STEP="systemd_service.sh"
source "$MODULES_DIR/systemd_service.sh"
echo "✅ Completed: $CURRENT_STEP"

CURRENT_STEP="disable_display_manager.sh"
source "$MODULES_DIR/disable_display_manager.sh"
echo "✅ Completed: $CURRENT_STEP"

CURRENT_STEP="autologin_tty1.sh"
source "$MODULES_DIR/autologin_tty1.sh"
echo "✅ Completed: $CURRENT_STEP"

CURRENT_STEP="xwrapper_config.sh"
source "$MODULES_DIR/wrapper_config.sh"
echo "✅ Completed: $CURRENT_STEP"

CURRENT_STEP="build_qt_app.sh"
source "$MODULES_DIR/build_qt_app.sh"
echo "✅ Completed: $CURRENT_STEP"

CURRENT_STEP="plymouth_theme.sh"
source "$MODULES_DIR/plymouth_theme.sh"
echo "✅ Completed: $CURRENT_STEP"

CURRENT_STEP="grub_bootloader.sh"
source "$MODULES_DIR/grub_bootloader.sh"
echo "✅ Completed: $CURRENT_STEP"

CURRENT_STEP="bash_profile_autostart.sh"
source "$MODULES_DIR/bash_profile_autostart.sh"
echo "✅ Completed: $CURRENT_STEP"


echo "🎉 All modules executed successfully. Please reboot your system to enter kiosk mode."
