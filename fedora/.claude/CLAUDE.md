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

## Key Config Groups

Most groups symlink to `$XDG_CONFIG_HOME/<group>/` or `$HOME`. Notable exceptions:

- **`shell/`** — Symlinks to `$HOME` (`.zshrc`, `.zshenv`, etc.); completions go to `$XDG_CONFIG_HOME/zsh/completions/`; `aliases.conf` goes to `$XDG_CONFIG_HOME/dnf5/aliases.d/` (dnf5 alias definitions). Many files are excluded (private env, history, etc.).
- **`binaries/`** and **`scripts/`** — Both symlink to `$CUSTOM_BIN_DIR` (custom PATH location for executables). `scripts/archive/` is excluded.
- **`claude-code/`** — Symlinks to `$HOME/.claude/`.
- **`codex/`** — Symlinks to `$HOME/.codex/`.
- **`git/`** — Symlinks to `$HOME` (gitconfig, gitignore, etc.).
- **`gpg/`** — Symlinks `gpg.conf` and `gpg-agent.conf` to `$HOME/.gnupg/`.
- **`system/`** — Mostly excluded from symlinking (see below); only `bookmarks` → `$XDG_CONFIG_HOME/gtk-3.0/` and `gsk.conf` → `$XDG_CONFIG_HOME/environment.d/` are symlinked.
- Groups with `"exclude": "all"` (atuin, gh, gtk, navi, npm, starship, tldr, zoxide) are present for reference/backup but not symlinked.

## System-Level Configs

Some configs can't be symlinked and must be copied to system paths (e.g., udev rules, systemd units). These directories use a `setup.sh` script that handles copying files to their required destinations, setting permissions, and reloading daemons. Must be run as root.

When adding new system-level config files, update the corresponding `setup.sh` to include them.

`system/setup.sh` manages:
- Power management scripts (`manage_nvidia_powerd.sh`, `switch_power_profile.sh`) → `/usr/local/bin/` (chmod +x)
- Udev rules (`98-auto-power-profile-change.rules`, `99-manage-nvidia-powerd.rules`) → `/etc/udev/rules.d/` (chmod 644)
- Systemd units (`auto-power-profile-check.service`, `auto-power-profile-check-timer.timer`) → `/etc/systemd/system/` (chmod 644)
- After copying: reloads udev rules, reloads systemd daemon, enables and starts the timer

Other files in `system/` (`.ini`, `.bak`, `.txt`, `.rules`, `.sh`) are excluded from symlinking — they are backups, reference files, or must be handled by `setup.sh`.
