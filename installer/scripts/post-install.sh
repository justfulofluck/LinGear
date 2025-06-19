#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration variables
INSTALL_DIR="/opt/kiosk"
CONFIG_DIR="/etc/kiosk"
FRAMEWORK_FILE="$CONFIG_DIR/framework"

# Print colored status messages
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if installation was completed
check_installation() {
    if [ ! -f "$FRAMEWORK_FILE" ]; then
        log_error "Installation not completed. Please run install.sh first"
        exit 1
    fi
    FRAMEWORK=$(cat "$FRAMEWORK_FILE")
    log_info "Detected framework: $FRAMEWORK"
}

# Verify framework-specific installation
verify_framework() {
    local framework=$1
    log_info "Verifying $framework installation..."

    case $framework in
        "tkinter")
            verify_tkinter
            ;;
        "qt")
            verify_qt
            ;;
        "lvgl")
            verify_lvgl
            ;;
        *)
            log_error "Unknown framework: $framework"
            return 1
            ;;
    esac
}

# Framework-specific verification functions
verify_tkinter() {
    python3 -c "import tkinter" || {
        log_error "Tkinter installation verification failed"
        return 1
    }
    log_info "Tkinter installation verified"
}

verify_qt() {
    which qmake6 || {
        log_error "Qt installation verification failed"
        return 1
    }
    log_info "Qt installation verified"
}

verify_lvgl() {
    [ -d "$INSTALL_DIR/lvgl" ] || {
        log_error "LVGL installation verification failed"
        return 1
    }
    log_info "LVGL installation verified"
}

# Configure display manager
setup_display() {
    log_info "Configuring display settings..."
    
    # Create X server configuration
    sudo mkdir -p /etc/X11/xorg.conf.d
    cat > /tmp/10-monitor.conf << EOF
Section "Monitor"
    Identifier "Monitor0"
    Option "DPMS" "false"
EndSection

Section "ServerFlags"
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
EndSection
EOF
    
    sudo mv /tmp/10-monitor.conf /etc/X11/xorg.conf.d/
}

# Enable and start services
activate_services() {
    log_info "Activating system services..."
    
    # Reload systemd configuration
    sudo systemctl daemon-reload
    
    # Enable and start kiosk service
    sudo systemctl enable kiosk.service
    sudo systemctl start kiosk.service
    
    # Check service status
    if ! systemctl is-active --quiet kiosk.service; then
        log_error "Failed to start kiosk service"
        return 1
    fi
}

# Perform final system checks
final_checks() {
    log_info "Performing final system checks..."
    
    # Check if X server is running
    if ! ps aux | grep -v grep | grep -q Xorg; then
        log_warn "X server is not running"
    fi
    
    # Check if kiosk application is running
    if ! ps aux | grep -v grep | grep -q "kiosk-launcher"; then
        log_error "Kiosk application is not running"
        return 1
    fi
    
    # Check system logs for errors
    if journalctl -u kiosk -n 50 --no-pager | grep -i error; then
        log_warn "Found errors in kiosk service logs"
    fi
}

# Print final instructions
print_final_instructions() {
    echo -e "\n=== Installation Complete ==="
    echo "Your kiosk system is now configured and running."
    echo "\nImportant Notes:"
    echo "1. The system will automatically start in kiosk mode on boot"
    echo "2. To stop the kiosk: sudo systemctl stop kiosk"
    echo "3. To start the kiosk: sudo systemctl start kiosk"
    echo "4. Logs can be viewed with: journalctl -u kiosk"
    echo "\nConfiguration files are located in: $CONFIG_DIR"
}

# Main execution
main() {
    log_info "Starting post-installation setup..."
    
    # Check if installation was completed
    check_installation
    
    # Verify framework installation
    verify_framework "$FRAMEWORK" || exit 1
    
    # Setup display configuration
    setup_display
    
    # Activate services
    activate_services || exit 1
    
    # Perform final checks
    final_checks
    
    # Print final instructions
    print_final_instructions
    
    log_info "Post-installation completed successfully"
}

# Run main function
main