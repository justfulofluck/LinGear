#!/bin/bash
set -e

log_info() { echo -e "\033[1;32m[INFO]\033[0m $1"; }

APP_NAME=$(cat /etc/kiosk/appname)
log_info "Installing app as '$APP_NAME'"

SRC_DIR="$(dirname "$(realpath "$0")")/../../../src/lvgl"
DEST_DIR="/opt/kiosk/$APP_NAME"

log_info "Setting up LVGL application..."
mkdir -p "$DEST_DIR"
cp -r "$SRC_DIR/"* "$DEST_DIR/"
cd "$DEST_DIR"

log_info "Running cmake and make..."
cmake .
make

log_info "LVGL application compiled successfully to $DEST_DIR"
