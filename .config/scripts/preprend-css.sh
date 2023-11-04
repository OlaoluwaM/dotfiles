#!/usr/bin/env bash

# I initially intended for this script to be used to re-add my custom gnome-shell css edits
# In the form of a css import at the top of the file

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <css-file> <css-statement>"
    exit 1
fi

CSS_FILE="$1"
CSS_STATEMENT="$2"
TEMP_FILE=$(mktemp)

awk -v cssStatement="$CSS_STATEMENT" '
/^\s*\/\*/ {
  print
  inCommentBlock = 1
  next
}

/^\s*\*\// {
  print
  inCommentBlock = 0
  next
}

/^\s*\S+/ {
  if (inCommentBlock) {
    print ""
    print cssStatement
    print ""
  }
  inCommentBlock = 0
}

{ print }
' "$CSS_FILE" >"$TEMP_FILE"

# mv "$TEMP_FILE" "$CSS_FILE"
mv "$TEMP_FILE" "cc.css"

echo "CSS statement added successfully to $CSS_FILE"
