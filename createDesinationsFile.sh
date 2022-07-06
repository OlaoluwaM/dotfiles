#!/usr/bin/env bash

for d in */; do
  test -f "${d}/destinations.json" && continue
  cat <<<'{ "!": "*" }' >"${d}/destinations.json"
done
echo 'DONE!'
