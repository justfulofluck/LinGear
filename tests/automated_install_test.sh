#!/bin/bash

# Automated Installation Test Script for LinGear
# Run this script in your VM to test the installation process automatically.

set -e  # Exit immediately if a command exits with a non-zero status.

PROJECT_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
INSTALLER_SCRIPT="$PROJECT_ROOT/installer/scripts/install.sh"
LINGEAR_SCRIPT="$PROJECT_ROOT/lingear"

echo "=== Starting Automated Installation Test ==="

# 1. Fix Permissions
echo "[TEST] Fixing permissions..."
if [ -f "$LINGEAR_SCRIPT" ]; then
    chmod +x "$LINGEAR_SCRIPT"
    echo "[TEST] Made 'lingear' executable."
else
    echo "[TEST] Warning: 'lingear' script not found at $LINGEAR_SCRIPT"
fi

find "$PROJECT_ROOT/installer/scripts" -name "*.sh" -exec chmod +x {} \;
echo "[TEST] Made installer scripts executable."

# 2. Simulate User Input
# Inputs:
# 1. Username: testuser
# 2. Password: testpassword
# 3. App Name: TestApp
# 4. Framework Choice: 1 (Qt)

echo "[TEST] Running installer with simulated input..."

# We use printf to pipe inputs to the script.
# The sequence corresponds to the 'read' commands in install.sh
# 1. APP_USER
# 2. APP_PASS
# 3. APP_NAME
# 4. Framework selection (1 for Qt)

printf "testuser\ntestpassword\nTestApp\n1\n" | sudo "$INSTALLER_SCRIPT"

# 3. Verify Result
if [ $? -eq 0 ]; then
    echo "=== Installation Test PASSED ==="
    echo "You can now verify the installation manually if needed."
else
    echo "=== Installation Test FAILED ==="
    exit 1
fi
