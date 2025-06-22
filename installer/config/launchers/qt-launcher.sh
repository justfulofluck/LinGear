#!/bin/bash
exec /opt/kiosk/$(cat /etc/kiosk/appname)/qt-app 2>> /tmp/qt-app-error.log
