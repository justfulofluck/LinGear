#!/bin/bash

echo "==> Installing and applying Plymouth splash screen... & Configuring Xwrapper permissions..."

# Define USER variables safely
USER_NAME=$(logname)
USER_HOME=$(eval echo ~$USER_NAME)

# Allow X to be started by any user
sudo mkdir -p /etc/X11
echo "allowed_users=anybody" | sudo tee /etc/X11/Xwrapper.config > /dev/null

# Disable graphical display managers if installed
for dm in lightdm gdm3 sddm xdm lxdm; do
  if systemctl status "$dm.service" &>/dev/null; then
    sudo systemctl disable "$dm.service"
    echo "Disabled $dm.service"
  fi
done

# Install plymouth and theme dependencies
sudo apt install -y plymouth plymouth-themes git

# Clone themes repo
mkdir -p "$USER_HOME/theme"
cd "$USER_HOME/theme"
if [ ! -d "plymouth-themes" ]; then
  git clone https://github.com/adi1090x/plymouth-themes.git
fi

# Copy and set the desired theme
sudo cp -r plymouth-themes/pack_4/spinner_alt /usr/share/plymouth/themes/
sudo chown -R $USER_NAME:$USER_NAME "$USER_HOME/theme"

sudo update-alternatives --install \
  /usr/share/plymouth/themes/default.plymouth default.plymouth \
  /usr/share/plymouth/themes/spinner_alt/spinner_alt.plymouth 100

sudo update-alternatives --set default.plymouth \
  /usr/share/plymouth/themes/spinner_alt/spinner_alt.plymouth

sudo update-initramfs -u
