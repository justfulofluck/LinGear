#!/bin/bash
set -e

log_info() { echo -e "\033[1;32m[INFO]\033[0m $1"; }

APP_NAME=$(cat /etc/kiosk/appname)
log_info "Installing app as '$APP_NAME'"

SRC_DIR="$(dirname "$(realpath "$0")")/../../../src/tkinter-app"
DEST_DIR="/opt/kiosk/$APP_NAME"

log_info "Setting up Tkinter application..."
mkdir -p "$DEST_DIR"
cp -r "$SRC_DIR/"* "$DEST_DIR/"

log_info "Installing Python requirements..."
pip3 install --upgrade pip
pip3 install -r "$DEST_DIR/requirements.txt"

log_info "Tkinter application installed to $DEST_DIR"
