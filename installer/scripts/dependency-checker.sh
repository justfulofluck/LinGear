#!/bin/bash

check_framework_dependencies() {
    local framework=$1
    echo "Checking dependencies for $framework..."

    case $framework in
        "tkinter")
            check_tkinter_deps
            ;;
        "qt")
            check_qt_deps
            ;;
        "lvgl")
            check_lvgl_deps
            ;;
        *)
            echo "Unknown framework: $framework"
            return 1
            ;;
    esac
}

check_tkinter_deps() {
    local deps=("python3" "python3-tk" "python3-pip")
    check_packages "${deps[@]}"
}

check_qt_deps() {
    local deps=("qt6-base-dev" "qt6-tools-dev" "cmake" "build-essential")
    check_packages "${deps[@]}"
}

check_lvgl_deps() {
    local deps=("build-essential" "libsdl2-dev" "cmake")
    check_packages "${deps[@]}"
}

check_packages() {
    local missing_deps=()
    for dep in "$@"; do
        if ! dpkg -l | grep -q "^ii.*$dep"; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi
    echo "All dependencies are installed"
    return 0
}

# Usage example
# check_framework_dependencies "tkinter"