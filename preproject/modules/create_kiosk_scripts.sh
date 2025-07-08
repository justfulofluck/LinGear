#!/bin/bash

echo "==> Creating kiosk startup scripts..."

sudo tee "$START_KIOSK_SH" > /dev/null <<EOF
#!/bin/bash
xinit $KIOSK_APP_SH -- :0
EOF
sudo chmod +x "$START_KIOSK_SH"

sudo tee "$KIOSK_APP_SH" > /dev/null <<EOF
#!/bin/bash
openbox &
exec $APP_PATH
EOF
sudo chmod +x "$KIOSK_APP_SH"

echo "==> Kiosk startup scripts created successfully."