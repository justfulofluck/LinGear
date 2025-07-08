#!/bin/bash

echo "==> Disabling graphical login manager..."
sudo systemctl disable lightdm || true
