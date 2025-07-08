#!/bin/bash

echo "==> Installing GUI, Qt and build packages..."
sudo apt update
sudo apt install -y \
  xserver-xorg xinit openbox qtbase5-dev qtdeclarative5-dev \
  qtquickcontrols2-5-dev qttools5-dev qtchooser build-essential git \
  qml-module-qtquick-controls qml-module-qtquick2 \
  qml-module-qtpositioning qml-module-qtlocation
