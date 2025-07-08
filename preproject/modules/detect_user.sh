#!/bin/bash

export USER_NAME=$(logname)
export USER_HOME="/home/$USER_NAME"
export APP_PATH="$USER_HOME/hello_qt"
export START_KIOSK_SH="/usr/local/bin/start-kiosk.sh"
export KIOSK_APP_SH="/usr/local/bin/kiosk-app.sh"
