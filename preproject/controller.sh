#!/bin/bash

set -e

echo "🚀 Starting Kiosk Setup..."

MODULES_DIR="./modules"

for module in "$MODULES_DIR"/*.sh; do
  echo ""
  echo "🔧 Running module: $(basename "$module")"
  source "$module"
done

echo ""
echo "✅ All modules executed successfully. Please reboot your system."
