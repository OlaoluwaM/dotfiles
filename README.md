# Dotfiles

A set of configuration files for my dev environment.

The `./makeSymlinks.mjs` script automatically creates the necessary symlinks. Also, each folder is fitted with a `destinations.json` file
incase you want to specify a destination for the symlink other than the default ($HOME).

The schema for the `destinations.json` is as follows

```json
{
  "filename": "string"
  ".gitConfig": "$HOME/git-things"
}
```

Yes, variables like `$HOME` and `~` work! If you want to specify a different path for all files in a folder you can do this

```json
{
  "*": "string"
  "*": "$HOME/git-things"
}
```

By default all files in each folder will be symlinked to the $HOME directory

**The script requires `zx` to run. It must be installed globally**

## Todos

- Distro specific options
