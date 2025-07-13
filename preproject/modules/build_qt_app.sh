#!/bin/bash

# Better input validation
validate_input() {
    local input=$1
    local name=$2
    
    if [ -z "$input" ]; then
        echo "$name cannot be empty."
        return 1
    fi
    
    # Check for invalid characters
    if [[ "$input" =~ [^a-zA-Z0-9_-] ]]; then
        echo "$name contains invalid characters. Use only letters, numbers, underscores and hyphens."
        return 1
    fi
    
    return 0
}

# Ask for project name with validation
while true; do
    read -p "Enter your Qt project name: " PROJECT_NAME
    if validate_input "$PROJECT_NAME" "Project name"; then
        break
    fi
done

# Ask for app name with validation
while true; do
    read -p "Enter your application name: " APP_NAME
    if validate_input "$APP_NAME" "Application name"; then
        break
    fi
done

# Set user home if not already set
USER_HOME="${USER_HOME:-$HOME}"

# Set app path to a different location than the build directory
BUILD_DIR="$USER_HOME/$PROJECT_NAME"
APP_PATH="/usr/local/bin/$APP_NAME"

echo "==> Building Qt Hello World application..."

# Check if build tools are available
if ! command -v qmake &> /dev/null; then
    echo "Error: qmake not found. Please ensure Qt development tools are installed."
    exit 1
fi

# Create backup if directory exists
if [ -d "$BUILD_DIR" ]; then
    BACKUP_DIR="$USER_HOME/${PROJECT_NAME}_backup_$(date +%Y%m%d%H%M%S)"
    echo "Directory already exists. Creating backup at $BACKUP_DIR"
    cp -r "$BUILD_DIR" "$BACKUP_DIR"
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || exit 1

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

cat > "$APP_NAME.pro" << EOF
QT += core gui widgets
CONFIG += c++11
TARGET = $APP_NAME
TEMPLATE = app
SOURCES += main.cpp
EOF

qmake "$APP_NAME.pro"
make

# Check if the build was successful
if [ ! -f "$APP_NAME" ]; then
    echo "Error: Build failed. Application binary not found."
    exit 1
fi

# Copy to a different location to avoid the same-file error
sudo mkdir -p $(dirname "$APP_PATH")
sudo cp "$APP_NAME" "$APP_PATH"
sudo chmod +x "$APP_PATH"
sudo chown $USER:$USER "$APP_PATH"

echo "==> Build complete. Application is at $APP_PATH"
