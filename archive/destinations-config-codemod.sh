#!/usr/bin/env bash

for dir in */; do
  if ! [[ -f "$dir/destinations.json" ]]; then
    echo -e "This ${dir} is not a config group. Skipping...\n"
    continue;
  fi

  echo "Ammending the destionations file for the ${dir} config group to support the new dfs CLI..."
  sd -s "!" "ignore" "$dir/destinations.json"
  sd -s "*" "all" "$dir/destinations.json"
  echo -e "Done\n"
done
