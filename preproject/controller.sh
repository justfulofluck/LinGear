#!/bin/bash

set -e

MODULES_DIR="./modules"
echo "🚀 Starting LinGear Setup..."

# Clock emoji animation
emoji_hour=( 0.08 '🕛' '🕐' '🕑' '🕒' '🕓' '🕔' '🕕' '🕖' '🕗' '🕘' '🕙' '🕚' )

# Trap to catch which module failed
trap 'echo -e "\n❌ Error occurred in: $CURRENT_STEP"; exit 1' ERR

# Clock animation function
clock_spin() {
    local pid=$1
    local i=1
    while kill -0 $pid 2>/dev/null; do
        printf " ${emoji_hour[i]}  "
        ((i=(i%12)+1))
        sleep "${emoji_hour[0]}"
        printf "\b\b\b\b\b"
    done
}

# Function to execute a module with animation
run_step() {
    CURRENT_STEP="$1"
    echo -n "🔧 Running: $CURRENT_STEP"
    ( source "$MODULES_DIR/$CURRENT_STEP" ) &
    clock_spin $!
    echo " ✅"
}

# Run each module in order
run_step "detect_user.sh"
run_step "install_packages.sh"
run_step "create_kiosk_scripts.sh"
run_step "systemd_service.sh"
run_step "disable_display_manager.sh"
run_step "autologin_tty1.sh"
run_step "xwrapper_config.sh"
run_step "build_qt_app.sh"
run_step "plymouth_theme.sh"
run_step "grub_bootloader.sh"
run_step "bash_profile_autostart.sh"

echo -e "\n🎉 All modules executed successfully. Please reboot your system to enter kiosk mode."
