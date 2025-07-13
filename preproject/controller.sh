#!/bin/bash

set -e

# Add version information
VERSION="1.0.0"
echo "🚀 Starting Kiosk Setup (v$VERSION)..."

# Add configuration file support
CONFIG_FILE="./kiosk_config.conf"
if [ -f "$CONFIG_FILE" ]; then
    echo "Loading configuration from $CONFIG_FILE"
    source "$CONFIG_FILE"
fi

MODULES_DIR="./modules"

# Add command line options
while getopts "hu:" opt; do
    case $opt in
        h)
            echo "Usage: $0 [-h] [-u username]" 
            echo "  -h: Show this help"
            echo "  -u: Specify username (default: current user)"
            exit 0
            ;;
        u)
            OVERRIDE_USER=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Add logging function
LOG_FILE="kiosk_setup.log"
function log {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Trap errors and print message
trap 'log "❌ Error occurred in: $CURRENT_STEP"; exit 1' ERR

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
