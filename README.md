# LinGear

**LinGear** is a modular, embedded Linux kiosk framework tailored for industrial and edge computing environments. It allows developers and integrators to deploy full-screen GUI applications—using **Qt (C++)** or **LVGL**—through a fully automated installer.

Unlike simple script runners, LinGear acts as an on-device build system. It **compiles your C++ source code** directly on the target machine and deploys the optimized binary for maximum performance.

---

## 🚀 Features

- 🔹 **Native Performance** — Compiles C++ code (Qt/LVGL) directly on the device.
- 🔹 **One-line Installer** — Automates dependency installation, compilation, and configuration.
- 🔹 **Seamless Boot** — Uses **Plymouth** to hide boot text and show a custom splash screen.
- 🔹 **Auto-login** — Boots directly into your GUI application without a login prompt.
- 🔹 **Secure Deployment** — Runs as a dedicated restricted user.

---

## 📋 Prerequisites

Before you begin, ensure you have:

1. **Hardware**: A Raspberry Pi, Industrial PC, or VM running Linux.
2. **OS**: Ubuntu 20.04/22.04 LTS or Debian 11/12 (Server or Desktop).
3. **Internet**: Required during installation to download dependencies.
4. **Sudo Access**: You must have root/sudo privileges.

---

## 🛠️ How to Setup (Client Guide)

Follow these simple steps to turn your fresh Linux installation into a dedicated Kiosk.

### Step 1: Download the Project

1. **Edit Code**: Modify your source files in `src/qt-app` or `src/lvgl-app`.
2. **Re-run Installer**:

    ```bash
    sudo ./installer/scripts/install.sh
    ```

3. **Select Same Options**: Choose the same App Name and Framework.
4. **Automatic Rebuild**: The installer will detect the changes, re-compile your binary, and replace the running version.

---

## ❓ Troubleshooting

**Q: My app doesn't start?**
A: Check the logs: `journalctl -u kiosk -e`

**Q: I see a "CMake Error"?**
A: Ensure your `CMakeLists.txt` in `src/qt-app` is correct and all required Qt modules are listed.

**Q: How do I stop the kiosk?**
A: SSH into the device or switch TTY (Ctrl+Alt+F2) and run: `sudo systemctl stop kiosk`

---

## 📬 Contact

<bhavanbadhe@gmail.com>
