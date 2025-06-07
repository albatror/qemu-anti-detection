#!/bin/bash
echo "--- Attempting to read libvirt configuration and logs ---"

QEMU_CONF="/etc/libvirt/qemu.conf"
LIBVIRTD_CONF="/etc/libvirt/libvirtd.conf" # Also check this one, as qemu.conf settings can be here too.
LOG_DIR="/var/log/libvirt/qemu/"
JOURNALCTL_CMD="journalctl -u libvirtd --no-pager -n 50" # Get recent 50 lines for libvirtd

echo "--- [Output] Reading $QEMU_CONF ---"
if [ -f "$QEMU_CONF" ]; then
    echo "Contents of $QEMU_CONF:"
    # Print lines that are not comments or empty
    grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$QEMU_CONF" || echo "No non-comment lines in $QEMU_CONF or grep failed."
else
    echo "INFO: $QEMU_CONF not found."
fi

echo "--- [Output] Reading $LIBVIRTD_CONF ---"
if [ -f "$LIBVIRTD_CONF" ]; then
    echo "Contents of $LIBVIRTD_CONF (relevant parts):"
    # Look for emulator path settings or security settings
    grep -E -i '^(emulator_path|qemu_binary|security_driver|log_filters|log_outputs)' "$LIBVIRTD_CONF" || echo "No relevant settings found or grep failed in $LIBVIRTD_CONF."
else
    echo "INFO: $LIBVIRTD_CONF not found."
fi

echo "--- [Output] Listing Libvirt QEMU logs in $LOG_DIR ---"
if [ -d "$LOG_DIR" ]; then
    ls -lt "$LOG_DIR" | head -n 10 # List newest 10 files/dirs
    # Attempt to read the latest log file if any exist
    LATEST_LOG=$(ls -t "$LOG_DIR"/*.log 2>/dev/null | head -n 1)
    if [ -n "$LATEST_LOG" ] && [ -f "$LATEST_LOG" ]; then
        echo "--- [Output] Contents of latest QEMU log: $LATEST_LOG (last 20 lines) ---"
        tail -n 20 "$LATEST_LOG" || echo "Failed to read $LATEST_LOG"
    else
        echo "INFO: No .log files found in $LOG_DIR or latest log is not readable."
    fi
else
    echo "INFO: Log directory $LOG_DIR not found."
fi

echo "--- [Output] Reading libvirtd journal logs (last 50 lines) ---"
if command -v journalctl &> /dev/null; then
    # This command would typically require sudo, but we'll try without for now.
    # In the actual environment, it might fail due to permissions.
    echo "Attempting to run: $JOURNALCTL_CMD (might require sudo)"
    eval "$JOURNALCTL_CMD" || echo "INFO: Failed to get journalctl logs for libvirtd. This might be due to permissions or the service not logging."
else
    echo "INFO: journalctl command not found."
fi

echo "--- [Output] End of libvirt investigation commands ---"
