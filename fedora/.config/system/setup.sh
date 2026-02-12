#!/bin/bash

# Automates the installation of power management udev rules, systemd units,
# and their associated scripts. Must be run as root (or with sudo).
#
# What this does:
# 1. Copies power management scripts to /usr/local/bin/ and marks them executable
# 2. Copies udev rules to /etc/udev/rules.d/ with proper permissions
# 3. Copies systemd service and timer units to /etc/systemd/system/
# 4. Reloads udev rules and triggers them
# 5. Reloads systemd, then enables and starts the timer

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UDEV_RULES_DIR="/etc/udev/rules.d"
SYSTEMD_DIR="/etc/systemd/system"
BIN_DIR="/usr/local/bin"

SCRIPTS=(
	"manage_nvidia_powerd.sh"
	"switch_power_profile.sh"
)

RULES=(
	"98-auto-power-profile-change.rules"
	"99-manage-nvidia-powerd.rules"
)

SYSTEMD_UNITS=(
	"auto-power-profile-check.service"
	"auto-power-profile-check-timer.timer"
)

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root (use sudo)." >&2
	exit 1
fi

echo "Installing power management scripts to $BIN_DIR..."
for script in "${SCRIPTS[@]}"; do
	cp "$SCRIPT_DIR/$script" "$BIN_DIR/$script"
	chmod +x "$BIN_DIR/$script"
	echo "  Installed $script"
done

echo "Installing udev rules to $UDEV_RULES_DIR..."
for rule in "${RULES[@]}"; do
	cp "$SCRIPT_DIR/$rule" "$UDEV_RULES_DIR/$rule"
	chmod 644 "$UDEV_RULES_DIR/$rule"
	echo "  Installed $rule"
done

echo "Installing systemd units to $SYSTEMD_DIR..."
for unit in "${SYSTEMD_UNITS[@]}"; do
	cp "$SCRIPT_DIR/$unit" "$SYSTEMD_DIR/$unit"
	chmod 644 "$SYSTEMD_DIR/$unit"
	echo "  Installed $unit"
done

echo "Reloading udev rules..."
udevadm control --reload-rules
udevadm trigger

echo "Reloading systemd and enabling timer..."
systemctl daemon-reload
systemctl enable --now auto-power-profile-check-timer.timer

echo "Done. Power management scripts, udev rules, and systemd units have been installed."
