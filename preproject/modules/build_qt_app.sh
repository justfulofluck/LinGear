#!/bin/bash

# Ask for project name
read -p "Enter your Qt project name: " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo "Project name cannot be empty."
    exit 1
fi

# Ask for app name
read -p "Enter your application name: " APP_NAME
if [ -z "$APP_NAME" ]; then
    echo "Application name cannot be empty."
    exit 1
fi

# Set user home if not already set
USER_HOME="${USER_HOME:-$HOME}"

# Set app path (you can modify this as needed)
APP_PATH="$USER_HOME/$PROJECT_NAME/$APP_NAME"

echo "==> Building Qt Hello World application..."

mkdir -p "$USER_HOME/$PROJECT_NAME"
cd "$USER_HOME/$PROJECT_NAME" || exit 1

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

sudo cp "$APP_NAME" "$APP_PATH"
sudo chmod +x "$APP_PATH"
sudo chown $USER:$USER "$APP_PATH"

echo "==> Build complete. Application is at $APP_PATH"
