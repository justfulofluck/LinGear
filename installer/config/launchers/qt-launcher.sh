#!/bin/bash
# Ensure Qt platform plugin path is set if needed, though usually auto-detected
export QT_QPA_PLATFORM=xcb
exec /opt/kiosk/$(cat /etc/kiosk/appname)/qt-app 2>> /tmp/qt-app-error.log
