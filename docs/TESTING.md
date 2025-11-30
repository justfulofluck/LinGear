# Testing Guide

This guide explains how to test your LinGear applications.

## Local Testing (On Development Machine)

Since LinGear apps are standard C++ applications (Qt or LVGL), you can build and run them on your local machine before deploying.

### Qt Applications

1. Navigate to your project directory.
2. Create a build folder:

    ```bash
    mkdir build && cd build
    ```

3. Compile:

    ```bash
    cmake ../src/qt-app
    make
    ```

4. Run:

    ```bash
    ./qt-app
    ```

## On-Device Testing

To test on the actual kiosk hardware:

1. **Deploy**: Use the CLI to build and push your code.

    ```bash
    ./lingear deploy
    ```

    *Note: This command builds the code and copies it to `/opt/kiosk/`. It then restarts the service.*

2. **View Logs**:
    If your app crashes or behaves unexpectedly, check the logs:

    ```bash
    journalctl -u kiosk -f
    ```

    This will show you the live output (stdout/stderr) of your application.

3. **Stop Kiosk**:
    To temporarily stop the kiosk mode (e.g., to use the desktop or terminal):

    ```bash
    sudo systemctl stop kiosk
    ```

4. **Start Kiosk**:
    To resume kiosk mode:

    ```bash
    sudo systemctl start kiosk
    ```
