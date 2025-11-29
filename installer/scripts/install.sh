#!/bin/bash

# Define installer directory early
INSTALLER_DIR="$(dirname "$(realpath "$0")")"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored status messages
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration variables
INSTALL_DIR="/opt/kiosk"
CONFIG_DIR="/etc/kiosk"
USER_NAME="$(whoami)"

# Prompt for credentials
read -rp "Enter the kiosk application username: " APP_USER
read -rsp "Enter the kiosk application password: " APP_PASS
echo ""
read -rp "Enter the kiosk application name: " APP_NAME

# Save credentials
sudo mkdir -p "$CONFIG_DIR"
echo "$APP_USER" | sudo tee "$CONFIG_DIR/user" > /dev/null
echo "$APP_PASS" | sudo tee "$CONFIG_DIR/pass" > /dev/null
echo "$APP_NAME" | sudo tee "$CONFIG_DIR/appname" > /dev/null

# Pre-installation checks
run_pre_install() {
    log_info "Running pre-installation checks..."
    if ! bash "$INSTALLER_DIR/pre-install.sh"; then
        log_error "Pre-installation checks failed"
        exit 1
    fi
}

# Framework selection
select_framework() {
    echo -e "\nSelect UI Framework:"
    echo "1) Qt C++ (Feature-rich)"
    echo "2) LVGL (Embedded-focused)"

    while true; do
        read -p "Enter choice [1-2]: " choice
        case $choice in
            1) echo "qt"; return ;;
            2) echo "lvgl"; return ;;
            *) echo "Invalid choice. Please select 1-2." ;;
        esac
    done
}

# Setup directories
setup_directories() {
    log_info "Creating installation directories..."
    sudo mkdir -p "$INSTALL_DIR" "$CONFIG_DIR"
    sudo chown "$USER_NAME:$USER_NAME" "$INSTALL_DIR" "$CONFIG_DIR"
}

# Install dependencies
install_framework_deps() {
    local framework=$1
    log_info "Installing $framework dependencies..."

    if ! bash "$INSTALLER_DIR/dependency-checker.sh" "$framework"; then
        log_error "Failed to install $framework dependencies"
        exit 1
    fi
}

# Auto-login configuration
setup_autologin() {
    local login_user
    login_user=$(cat "$CONFIG_DIR/user")

    sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
    sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $login_user --noclear %I \$TERM
EOF

    log_info "Auto-login configured for user: $login_user"
}

# Kiosk service setup
setup_kiosk_service() {
    local framework=$1
    log_info "Setting up kiosk systemd service..."

    sudo cp "$INSTALLER_DIR/../config/kiosk.service" /etc/systemd/system/kiosk.service
    sudo sed -i "s/%USER%/$USER_NAME/g" /etc/systemd/system/kiosk.service

    sudo cp "$INSTALLER_DIR/../config/launchers/${framework}-launcher.sh" /usr/local/bin/kiosk-launcher.sh
    sudo chmod +x /usr/local/bin/kiosk-launcher.sh
}

# Build application
build_application() {
    local framework=$1
    log_info "Building $framework application..."
    
    local src_dir="$INSTALLER_DIR/../../src/${framework}-app"
    
    if [ ! -d "$src_dir" ]; then
        log_error "Source directory not found: $src_dir"
        exit 1
    fi

    cd "$src_dir" || exit 1
    
    # Clean previous build
    rm -rf build
    mkdir -p build
    cd build || exit 1

    # Run CMake and Make
    if ! cmake ..; then
        log_error "CMake configuration failed"
        exit 1
    fi

    if ! make -j$(nproc); then
        log_error "Build failed"
        exit 1
    fi
    
    log_info "Build successful"
}

# Deploy application
deploy_application() {
    local framework=$1
    log_info "Deploying application to $INSTALL_DIR/$APP_NAME..."

    local build_dir="$INSTALLER_DIR/../../src/${framework}-app/build"
    local target_dir="$INSTALL_DIR/$APP_NAME"
    
    sudo mkdir -p "$target_dir"
    
    # Copy artifacts based on framework
    if [ "$framework" == "qt" ]; then
        # Assuming binary name is 'qt-app' based on standard CMakeLists
        if [ -f "$build_dir/qt-app" ]; then
            sudo cp "$build_dir/qt-app" "$target_dir/"
        else
            log_error "Compiled binary 'qt-app' not found"
            exit 1
        fi
    elif [ "$framework" == "lvgl" ]; then
        if [ -f "$build_dir/lvgl-app" ]; then
             sudo cp "$build_dir/lvgl-app" "$target_dir/"
        else
             log_error "Compiled binary 'lvgl-app' not found"
             exit 1
        fi
    fi
    
    sudo chown -R "$USER_NAME:$USER_NAME" "$target_dir"
    sudo chmod +x "$target_dir"/*
}

# Setup Plymouth splash
setup_plymouth() {
    log_info "Setting up Plymouth boot splash..."
    chmod +x "$INSTALLER_DIR/../plymouth/setup-plymouth.sh"
    bash "$INSTALLER_DIR/../plymouth/setup-plymouth.sh"
}

# Main process
main() {
    log_info "Starting kiosk installation..."

    run_pre_install

    framework=$(select_framework)
    log_info "Selected framework: $framework"

    setup_directories
    install_framework_deps "$framework"
    build_application "$framework"
    deploy_application "$framework"
    setup_autologin
    setup_kiosk_service "$framework"
    setup_plymouth

    log_info "Installation completed successfully."
    log_info "Please run post-install.sh to complete the setup."
}

# Run installation
main
