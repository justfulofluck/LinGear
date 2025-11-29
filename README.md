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

Open a terminal on your device and clone the repository:

```bash
git clone https://github.com/yourusername/LinGear.git
cd LinGear
```

### Step 2: Prepare Your Application

Place your C++ source code in the `src` directory.

- **For Qt Apps**: Put your code in `src/qt-app/`. Ensure you have a `CMakeLists.txt`.
- **For LVGL Apps**: Put your code in `src/lvgl-app/`.

> **Note:** The project comes with "Hello World" examples by default, so you can test it immediately without writing code.

### Step 3: Run the Installer

Navigate to the installer script and run it:

```bash
cd installer/scripts
sudo ./install.sh
```

### Step 4: Follow the Prompts

The installer will ask you a few questions:

1. **Username**: Enter a name for the kiosk user (e.g., `mydevice`).
2. **Password**: Set a password for this user.
3. **App Name**: Give your application a name (e.g., `MyDisplay`).
4. **Framework**: Choose **1** for Qt or **2** for LVGL.

### Step 5: Reboot

Once the installation is complete, reboot your system:

```bash
sudo reboot
```

Your system will now boot past the text logs, show a splash screen, and launch your application automatically!

---

## 📁 Project Structure

```
LinGear/
├── installer/           
│   ├── scripts/         # Logic for install, build, and deploy
│   ├── config/          # Systemd services and launchers
│   └── plymouth/        # Boot splash themes
├── src/
│   ├── qt-app/          # Your Qt C++ source code
│   └── lvgl-app/        # Your LVGL C++ source code
```

---

## 🔧 Development Workflow

To update your application after the initial installation:

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
