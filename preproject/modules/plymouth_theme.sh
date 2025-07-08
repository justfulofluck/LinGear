#!/bin/bash

echo "==> Installing and applying Plymouth splash screen..."

sudo apt install -y plymouth plymouth-themes git
mkdir -p "$USER_HOME/theme"
cd "$USER_HOME/theme"
git clone https://github.com/adi1090x/plymouth-themes.git

sudo cp -r plymouth-themes/pack_4/spinner_alt /usr/share/plymouth/themes/
sudo chown -R $USER_NAME:$USER_NAME "$USER_HOME/theme"

sudo update-alternatives --install \
  /usr/share/plymouth/themes/default.plymouth default.plymouth \
  /usr/share/plymouth/themes/spinner_alt/spinner_alt.plymouth 100

sudo update-alternatives --set default.plymouth \
  /usr/share/plymouth/themes/spinner_alt/spinner_alt.plymouth

sudo update-initramfs -u
