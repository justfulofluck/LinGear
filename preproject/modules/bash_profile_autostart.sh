#!/bin/bash

echo "==> Configuring ~/.bash_profile to auto-start X session..."

BASH_PROFILE="$USER_HOME/.bash_profile"

if ! grep -q "startx $KIOSK_APP_SH" "$BASH_PROFILE" 2>/dev/null; then
  cat >> "$BASH_PROFILE" <<EOF

# Auto-start kiosk on tty1
if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    startx $KIOSK_APP_SH
fi
EOF
fi

echo "==> Disabling kiosk.service to allow tty1 login startup method..."
sudo systemctl disable kiosk.service || true
