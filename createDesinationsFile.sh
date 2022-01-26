#!/usr/bin/env bash

for d in */; do
  ! [[ -f "${d}/destinations.json" ]] && echo "{}" > "${d}/destinations.json"
done
echo 'DONE!'
