#!/bin/bash

echo "=== Pre-installation System Check ==="

check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "Detected OS: $NAME $VERSION_ID"
    else
        echo "Warning: Unable to determine OS version"
    fi
}

check_dependencies() {
    local deps=("python3" "git" "cmake" "gcc" "g++")
    local missing_deps=()

    echo "\nChecking basic dependencies..."
    for dep in "${deps[@]}"; do
        if ! command -v $dep >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi
    echo "All basic dependencies are installed"
    return 0
}

check_disk_space() {
    local required_space=5000000  # 5GB in KB
    local available_space=$(df -k . | awk 'NR==2 {print $4}')

    echo "\nChecking available disk space..."
    if [ $available_space -lt $required_space ]; then
        echo "Error: Insufficient disk space. Required: 5GB, Available: $(($available_space/1024/1024))GB"
        return 1
    fi
    echo "Sufficient disk space available"
    return 0
}

check_memory() {
    local required_memory=2000000  # 2GB in KB
    local available_memory=$(free -k | awk '/Mem:/ {print $2}')

    echo "\nChecking system memory..."
    if [ $available_memory -lt $required_memory ]; then
        echo "Warning: Low memory. Recommended: 2GB, Available: $(($available_memory/1024/1024))GB"
    else
        echo "Sufficient memory available"
    fi
}

# Main execution
check_os
check_dependencies || exit 1
check_disk_space || exit 1
check_memory

echo "\n=== Pre-installation checks completed successfully ==="