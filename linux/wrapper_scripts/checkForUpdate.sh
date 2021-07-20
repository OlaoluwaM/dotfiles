#!/usr/bin/env bash

# UPDATES_AVAILABLE=$(apt-get upgrade --dry-run | grep -o -E '[0-9]+ upgraded' | grep -o -E '[0-9]+')
SCRIPT_DIR=$(dirname $(realpath $0))
UPDATES_AVAILABLE=$(aptitude search '~U' | wc -l)

if [ $UPDATES_AVAILABLE -gt 0 ]; then
     sudo "${SCRIPT_DIR}/aptituteUpdate.sh" >/dev/null 2>&1

  if [ $UPDATES_AVAILABLE -gt 1 ]; then
    echo "Updated ${UPDATES_AVAILABLE} packages at $(date)"
  else
    echo "Updated ${UPDATES_AVAILABLE} package at $(date)"
  fi

else
  echo "No updates yet $(date)" 

fi

