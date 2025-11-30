# Installation Guide

This guide covers how to set up the **LinGear** framework on your development machine or target device.

## Prerequisites

* **OS**: Ubuntu 20.04/22.04 LTS or Debian 11/12.
* **Permissions**: Root (sudo) access is required.
* **Internet**: Required for downloading dependencies.

## Quick Start (CLI)

The easiest way to install LinGear is using the CLI tool.

1. **Clone the Repository**:

    ```bash
    git clone https://github.com/yourusername/LinGear.git
    cd LinGear
    ```

2. **Run the Installer**:

    ```bash
    ./lingear install
    ```

    This will launch the installation wizard which will:
    * Install system dependencies (Qt, compilers, etc.).
    * Create the `kiosk` user.
    * Set up the systemd service.
    * Configure the boot splash.

## Manual Installation

If you prefer to run the scripts manually:

1. Navigate to the scripts directory:

    ```bash
    cd installer/scripts
    ```

2. Run the install script:

    ```bash
    sudo ./install.sh
    ```

## Post-Installation

After installation, your system is ready to deploy applications.
You can verify the installation by running:

```bash
./lingear doctor
```
