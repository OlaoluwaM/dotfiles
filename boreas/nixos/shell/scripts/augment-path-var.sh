#!/usr/bin/env bash

pathsToAdd=(".local/bin" "go/bin")

for pathToDir in "${pathsToAdd[@]}"; do
   if ! echo $PATH | grep -q "$HOME/$pathToDir"; then
      [ -d "$HOME/$pathToDir" ] && PATH="$PATH:$HOME/$pathToDir"
   fi
done
