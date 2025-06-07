#!/bin/bash
echo "--- Attempting direct execution of diagnostic commands ---"

echo "--- [Output] Checking for QEMU binary in /usr/local/bin ---"
if [ -f "/usr/local/bin/qemu-system-x86_64" ]; then
    ls -l /usr/local/bin/qemu-system-x86_64
else
    echo "INFO: qemu-system-x86_64 not found in /usr/local/bin."
fi

echo "--- [Output] File permissions and ownership for /usr/local/bin/qemu-system-x86_64 ---"
if [ -f "/usr/local/bin/qemu-system-x86_64" ]; then
    stat /usr/local/bin/qemu-system-x86_64
else
    echo "INFO: Skipping stat for /usr/local/bin/qemu-system-x86_64 as it's not found."
fi

echo "--- [Output] Current user PATH (build environment) ---"
echo "Current user PATH: $PATH"
if [[ ":$PATH:" == *":/usr/local/bin:"* ]]; then
  echo "INFO: /usr/local/bin is in the current user's PATH."
else
  echo "WARNING: /usr/local/bin is NOT in the current user's PATH."
fi

echo "--- [Output] Checking for official QEMU in /usr/bin ---"
if [ -f "/usr/bin/qemu-system-x86_64" ]; then
    ls -l /usr/bin/qemu-system-x86_64
    echo "INFO: Official QEMU found in /usr/bin."
else
    echo "INFO: Official qemu-system-x86_64 not found in /usr/bin."
fi

echo "--- [Output] Basic check for libvirtd service ---"
if command -v systemctl &> /dev/null; then
    if systemctl is-active libvirtd &> /dev/null; then
        echo "INFO: libvirtd service is active (checked via systemctl)."
    else
        echo "INFO: libvirtd service is not active or not found via systemctl."
    fi
else
    echo "INFO: systemctl command not found, cannot check libvirtd status."
fi

echo "--- [Output] End of direct diagnostic commands ---"
