# OBS Studio Configuration

On Fedora, OBS Studio is installed as a Flatpak. Flatpak apps store their config under `~/.var/app/` rather than `~/.config/`, so OBS config lives at:

```
~/.var/app/com.obsproject.Studio/config/obs-studio/
```

## Directory Structure

- `basic/` — scenes, profiles, stream settings
- `global.ini` — app-level preferences
- `plugin_config/` — per-plugin settings

## Restoring from Backup

1. Close OBS if it's running.
2. Copy the backed-up `obs-studio/` folder into `~/.var/app/com.obsproject.Studio/config/obs-studio/`.
3. Launch OBS — everything should pick up.

If the backup came from a native (non-Flatpak) install, the config was likely in `~/.config/obs-studio/` — the contents are the same, just copy them to the Flatpak path above. Scenes referencing absolute paths (e.g., media sources) may need adjustment, since Flatpak OBS has a sandboxed filesystem view.
