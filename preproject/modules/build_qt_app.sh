#!/bin/bash

echo "==> Building Qt Hello World application..."

mkdir -p "$USER_HOME/qt-kiosk-app"
cd "$USER_HOME/qt-kiosk-app"

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

cat > hello_qt.pro << 'EOF'
QT += core gui widgets
CONFIG += c++11
TARGET = hello_qt
TEMPLATE = app
SOURCES += main.cpp
EOF

qmake hello_qt.pro
make

sudo cp hello_qt "$APP_PATH"
sudo chmod +x "$APP_PATH"
sudo chown $USER_NAME:$USER_NAME "$APP_PATH"

echo "==> Qt Hello World application built successfully."