# OBS Studio Configuration

OBS Studio stores its user configuration in `~/.config/obs-studio/`. This is standard across Linux distros — on NixOS, the Nix store only holds the OBS binary and plugins, not user config.

## Directory Structure

- `basic/` — scenes, profiles, stream settings
- `global.ini` — app-level preferences
- `plugin_config/` — per-plugin settings

## Restoring from Backup

1. Close OBS if it's running.
2. Copy the backed-up `obs-studio/` folder into `~/.config/obs-studio/`.
3. Launch OBS — everything should pick up.

If the backup came from a different OS or a significantly older OBS version, scenes referencing absolute paths (e.g., media sources) may need path adjustments.
