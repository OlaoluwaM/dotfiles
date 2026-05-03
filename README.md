# Dotfiles

A set of configuration files for my machines. Each machine/host will have it's own directory with subdirectories for the different OSes I have used or plan to use on the machine. For any new machine/host should be given a name, ideally from greek mythology, and a directory for it created here

## Note on the top-level `fedora` dir

This is going to be deprecated as I move on to having dotfiles be host based. Currently `./fedora/.config` is a symlink to `./boreas/fedora`. Once I've moved boreas (my asus system) on to nixos we can delete it and update the `DOTS` env variable to match its path

## Note on the top-level `nixos` dir

Deprecated. Currently being used by a work system so it needs to remain for now

## For symlinks prefer relative symlinks

Use the command `ln -svfnrT <SOURCE> <TARGET>` at the top level of this directory using relative paths for both `SOURCE` and `TARGET`. For example, `ln -svfnrT boreas/common/yt-dlp boreas/nixos/yt-dlp`
