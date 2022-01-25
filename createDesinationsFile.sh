#!/usr/bin/env bash

for d in */; do
  ! [[ -f "${d}/destinations.json" ]] && touch "${d}/destinations.json"
done
echo 'DONE!'
