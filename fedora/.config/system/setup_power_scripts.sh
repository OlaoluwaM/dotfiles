#!/bin/bash

# Automates the installation of power management udev rules and their associated scripts.
# Must be run as root (or with sudo).
#
# What this does:
# 1. Copies power management scripts to /usr/local/bin/ and marks them executable
# 2. Copies both udev rules to /etc/udev/rules.d/ with proper permissions
# 3. Reloads udev rules and triggers them

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UDEV_RULES_DIR="/etc/udev/rules.d"
BIN_DIR="/usr/local/bin"

SCRIPTS=(
	"manage_nvidia_powerd.sh"
	"switch_power_profile.sh"
)

RULES=(
	"98-auto-power-profile-change.rules"
	"99-manage-nvidia-powerd.rules"
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

echo "Reloading udev rules..."
udevadm control --reload-rules
udevadm trigger

echo "Done. Power management scripts and udev rules have been installed."
