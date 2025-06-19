#!/bin/bash

# Function to install Plymouth and dependencies
install_plymouth() {
    echo "Installing Plymouth and dependencies..."
    apt-get update
    apt-get install -y plymouth plymouth-themes
}

# Function to create a custom theme
create_custom_theme() {
    local THEME_NAME="kiosk-splash"
    local THEME_DIR="/usr/share/plymouth/themes/$THEME_NAME"
    
    echo "Creating custom Plymouth theme..."
    mkdir -p "$THEME_DIR"
    
    # Create theme script file
    cat > "$THEME_DIR/$THEME_NAME.script" << 'EOF'
Window.SetBackgroundTopColor(0.0, 0.0, 0.0);     # Black background
Window.SetBackgroundBottomColor(0.0, 0.0, 0.0);

logo.image = Image("logo.png");
logo.sprite = Sprite(logo.image);
logo.opacity_angle = 0;

fun refresh_callback() {
    logo.sprite.SetX(Window.GetWidth() / 2 - logo.image.GetWidth() / 2);
    logo.sprite.SetY(Window.GetHeight() / 2 - logo.image.GetHeight() / 2);
}

Plymouth.SetRefreshFunction(refresh_callback);
EOF

    # Create theme configuration file
    cat > "$THEME_DIR/$THEME_NAME.plymouth" << EOF
[Plymouth Theme]
Name=$THEME_NAME
Description=Custom kiosk boot splash theme
ModuleName=script

[script]
ImageDir=$THEME_DIR
ScriptFile=$THEME_DIR/$THEME_NAME.script
EOF

    # Copy logo image
    cp "$(dirname "$0")/assets/logo.png" "$THEME_DIR/"
}

# Function to configure Plymouth
configure_plymouth() {
    local THEME_NAME="kiosk-splash"
    
    echo "Configuring Plymouth..."
    # Update initramfs configuration
    echo "FRAMEBUFFER=y" > /etc/initramfs-tools/conf.d/splash
    
    # Set as default theme
    plymouth-set-default-theme -R "$THEME_NAME"
    
    # Update initramfs
    update-initramfs -u
}

# Main function
main() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
    
    install_plymouth
    create_custom_theme
    configure_plymouth
    
    echo "Plymouth theme setup completed successfully"
}

main