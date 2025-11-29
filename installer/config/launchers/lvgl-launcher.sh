#!/bin/bash
exec /opt/kiosk/$(cat /etc/kiosk/appname)/lvgl-app 2>> /tmp/lvgl-app-error.log
