# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the Fedora-specific subdirectory of a multi-distro dotfiles monorepo (`dotfiles/`). Sibling directories include `mac/` and `nixos/`. The git root is at `/home/olaolu/Desktop/dotfiles`.

## Dotfiles Management: Dotfilers

Dotfiles are managed with [dotfilers](https://github.com/OlaoluwaM/dotfilers), a bespoke CLI tool. Key concepts:

- **Configuration groups**: Each subdirectory under `.config/` that contains a `destinations.json` is a config group.
- **`destinations.json`**: Maps files to their symlink destinations. Supports shell variables (`$HOME`, `$XDG_CONFIG_HOME`, custom vars like `$CUSTOM_BIN_DIR`), glob patterns, and reserved keys:
  - `"all"` — default destination for unmapped files
  - `"exclude"` — files/patterns to skip (array of strings or `"all"`)
- **`$DOTS`**: Environment variable pointing to the `.config/` directory. Required by dotfilers.
- **Commands**: `dotfilers link [group]` to create symlinks, `dotfilers unlink [group]` to remove them.

When adding new config files, either add them to an existing config group or create a new directory with a `destinations.json`.

## System-Level Configs

Some configs can't be symlinked and must be copied to system paths (e.g., udev rules, systemd units). These directories use a `setup.sh` script that handles copying files to their required destinations, setting permissions, and reloading daemons. Must be run as root.

When adding new system-level config files, update the corresponding `setup.sh` to include them.

Currently, `.config/system/setup.sh` manages:
- Power management scripts → `/usr/local/bin/`
- Udev rules → `/etc/udev/rules.d/`
- Systemd service/timer units → `/etc/systemd/system/`
