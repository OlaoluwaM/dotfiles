# Ilyamiro Baseline

This directory vendors a sanitized baseline from
<https://github.com/ilyamiro/nixos-configuration>.

It is intentionally a baseline, not an upstream mirror. The Nix config owns the
packages, services, session startup, and symlinks; these files stay here because
the Quickshell/QML side is large, iterative, and easier to rice as normal
dotfiles.

Removed from the baseline:

- The updater and installer surfaces that reference `ilyamiro/imperative-dots`.
- The guide surface that links back into the installer flow.
- OpenWeather/calendar integration and weather API-key handling.
- Online wallpaper search and DDG download helpers.
- The settings popup, because the upstream version includes weather/API-key UI.

Keep future changes deliberate: if a removed feature comes back, add it as a
separate reviewed change rather than by refreshing the whole upstream tree.
