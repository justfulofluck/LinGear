# Troubleshooting Guide

Common issues and solutions for LinGear.

## Diagnostic Tool

Run the built-in doctor command to check for common system issues:

```bash
./lingear doctor
```

## Common Issues

### 1. Application Fails to Start

**Symptoms**: The screen is black, or returns to the splash screen repeatedly.
**Fix**:
Check the service logs:

```bash
journalctl -u kiosk -n 50 --no-pager
```

* **"Exec format error"**: You might be trying to run an x86 binary on an ARM (Pi) device. Ensure you compiled the code *on the device* using `./lingear build`.
* **"Shared library not found"**: You are missing a dependency. Run `./lingear install` again to ensure all deps are installed.

### 2. "Display not found" (Qt)

**Symptoms**: App crashes with `Could not connect to display`.
**Fix**:

* Ensure the X server is running.
* Try setting the platform manually in your launcher script:
    `export QT_QPA_PLATFORM=xcb` (or `linuxfb` if not using X11).

### 3. Permissions Errors

**Symptoms**: App cannot write to files or access hardware.
**Fix**:
The app runs as the `kiosk` user. Ensure this user has the right permissions:

```bash
sudo usermod -aG video,gpio,i2c kiosk
```

### 4. Boot Splash Doesn't Show

**Symptoms**: You still see text scrolling during boot.
**Fix**:
Re-run the Plymouth setup:

```bash
sudo installer/plymouth/setup-plymouth.sh
```
