#!/bin/bash

echo "==> Creating kiosk startup scripts..."

sudo tee "$START_KIOSK_SH" > /dev/null <<EOF
#!/bin/bash
xinit $KIOSK_APP_SH -- :0
EOF
sudo chown root:$KIOSK_GROUP "$START_KIOSK_SH"
sudo chmod 750 "$START_KIOSK_SH"

sudo tee "$KIOSK_APP_SH" > /dev/null <<EOF
#!/bin/bash
openbox &
exec $APP_PATH
EOF
sudo chown root:$KIOSK_GROUP "$KIOSK_APP_SH"
sudo chmod 750 "$KIOSK_APP_SH"

echo "==> Kiosk startup scripts created successfully."