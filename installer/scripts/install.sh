#!/bin/bash

read -rp "Enter the kiosk application username: " APP_USER
read -rsp "Enter the kiosk application password: " APP_PASS
echo ""
read -rp "Enter the kiosk application name: " APP_NAME

# Save them to config for later use
mkdir -p /etc/kiosk
echo "$APP_USER" > /etc/kiosk/user
echo "$APP_PASS" > /etc/kiosk/pass
echo "$APP_NAME" > /etc/kiosk/appname


# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration variables
INSTALL_DIR="/opt/kiosk"
CONFIG_DIR="/etc/kiosk"
USER_NAME="$(whoami)"

# Print colored status messages
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Run pre-installation checks
run_pre_install() {
    log_info "Running pre-installation checks..."
    if ! ./pre-install.sh; then
        log_error "Pre-installation checks failed"
        exit 1
    fi
}

# Framework selection menu
select_framework() {
    echo -e "\nSelect UI Framework:"
    echo "1) Tkinter (Python-based)"
    echo "2) Qt C++ (Feature-rich)"
    echo "3) LVGL (Embedded-focused)"
    
    while true; do
        read -p "Enter choice [1-3]: " choice
        case $choice in
            1) echo "tkinter"; return ;;
            2) echo "qt"; return ;;
            3) echo "lvgl"; return ;;
            *) echo "Invalid choice. Please select 1-3" ;;
        esac
    done
}

# Create necessary directories
setup_directories() {
    log_info "Creating installation directories..."
    sudo mkdir -p "$INSTALL_DIR" "$CONFIG_DIR"
    sudo chown "$USER_NAME:$USER_NAME" "$INSTALL_DIR" "$CONFIG_DIR"
}

# Install framework-specific dependencies
install_framework_deps() {
    local framework=$1
    log_info "Installing $framework dependencies..."
    
    if ! ./dependency-checker.sh "$framework"; then
        log_error "Failed to install $framework dependencies"
        return 1
    fi
}

# Configure auto-login
setup_autologin() {
APP_USER=$(cat /etc/kiosk/user)

mkdir -p /etc/systemd/system/getty@tty1.service.d
cat <<EOF > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $APP_USER --noclear %I \$TERM
EOF

log_info "Auto-login configured for user: $APP_USER"
}

# Configure kiosk service
setup_kiosk_service() {
    local framework=$1
    log_info "Setting up kiosk service..."
    
    # Copy and configure service file
    sudo cp ../config/kiosk.service /etc/systemd/system/
    sudo sed -i "s/%USER%/$USER_NAME/g" /etc/systemd/system/kiosk.service
    
    # Create launcher script
    sudo cp "../config/launchers/$framework-launcher.sh" \
        /usr/local/bin/kiosk-launcher.sh
    sudo chmod +x /usr/local/bin/kiosk-launcher.sh
}

# Main installation process
main() {
    log_info "Starting kiosk installation..."
    
    # Run pre-installation checks
    run_pre_install
    
    # Select framework
    framework=$(select_framework)
    log_info "Selected framework: $framework"
    
    # Setup basic structure
    setup_directories
    
    # Install dependencies
    install_framework_deps "$framework"
    
    # Configure system
    setup_autologin
    setup_kiosk_service "$framework"
    
    log_info "Installation completed successfully"
    log_info "Please run post-install.sh to complete the setup"
}

# ... existing code ...

# Setup Plymouth theme
echo "Setting up Plymouth boot splash..."
chmod +x "$INSTALLER_DIR/plymouth/setup-plymouth.sh"
"$INSTALLER_DIR/plymouth/setup-plymouth.sh"

# ... existing code ...

# Run main installation
main